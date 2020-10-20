import UIKit

/// An object that displays a static or an animated image in your interface.
@IBDesignable open class LoopView: UIImageView {
    private var memoryWarningObserver: AnyObject?
    private var loopRenderer: LoopRenderer? {
        didSet {
            if loopRenderer != nil {
                startObservingMemoryWarnings()
            } else {
                stopObservingMemoryWarnings()
            }
        }
    }

    /// A callback handler called at the completion play cycle.
    public typealias CompletionCallback = (Bool) -> Void

    private var completion: CompletionCallback?

    /// The delegate of the loop view object.
    open weak var delegate: LoopViewDelegate?

    /// The activity delegate of the loop view object.
    open weak var activityDelegate: LoopViewActivityDelegate?

    /// A list of behavior following the completion of the play cycle.
    public enum CompletionBehavior {

        /// Stops the rendering once completion is reached.
        case stop

        /// Pauses the rendering once completion is reached.
        case pause
    }

    /// The webp image being displayed.
    open var loopImage: LoopImage? {
        willSet {
            stop()
        } didSet {
            configureRenderer()
            autoplayAnimationIfNeeded()
        }
    }

    /// The placeholder image displayed when the animation is stopped.
    open var placeholderImage: UIImage? {
        didSet {
            if !isPlaying {
                image = placeholderImage
            }
        }
    }

    /// A flag to determine if the view should start playing images automatically.
    ///
    /// This property is set to `true` by default.
    @IBInspectable open var autoPlay = true {
        didSet {
            autoplayAnimationIfNeeded()
        }
    }

    /// The speed factor at which the animation should be played (limited by the display refresh rate).
    /// - Important: Non-negative.
    @IBInspectable open var playBackSpeedRate: Double = 1 {
        didSet {
            loopRenderer?.playBackSpeedRate = playBackSpeedRate
        }
    }

    /// The amount of time the animation should play, overriding the amount set in the image.
    open var loopMode: LoopImage.LoopMode? {
        didSet {
            loopRenderer?.viewLoopMode = loopMode
            autoplayAnimationIfNeeded()
        }
    }

    /// The behavior following the completion of the play cycle.
    open var completionBehavior: CompletionBehavior = .stop

    /// Returns true if the image animation is playing.
    open var isPlaying: Bool {
        return loopRenderer?.isRendering == true
    }

    /// Returns an loop view initialized with the specified image.
    /// - Parameter loopImage: The initial image to display in the loop view.
    /// - Parameter placeholderImage: The placeholder image to display when the animation is stopped.
    public convenience init(loopImage: LoopImage?, placeholderImage: UIImage? = nil) {
        self.init()
        self.loopImage = loopImage
        self.placeholderImage = placeholderImage
        configureRenderer()
    }

    deinit {
        stopObservingMemoryWarnings()
    }

    /// Plays the animation of the image.
    /// - Parameters:
    ///   - loopMode: The amount of time the animation should play or left to nil to keep current behavior.
    ///   - useCache: A flag to determine if the frames generated should be cached or left to nil to keep current behavior.
    ///   - completion: The callback handler called at the completion play cycle.
    open func play(loopMode: LoopImage.LoopMode? = nil, completion: CompletionCallback? = nil) {
        if let loopMode = loopMode {
            self.loopMode = loopMode
        }

        if let completion = completion {
            self.completion = completion
        }

        loopRenderer?.start()
    }

    /// Seeks to a position in the animation.
    /// - Parameter progress: The progress at which we want to seek into the animation.
    /// - Parameter shouldResumePlaying: A flag to indicate if we want to resume playing the animation after seeking.
    open func seek(progress: Double, shouldResumePlaying: Bool) {
        loopRenderer?.seek(progress: progress, shouldResumePlaying: shouldResumePlaying)
    }

    /// Plays the animation of the image.
    /// - Parameter completion: The callback handler called at the completion play cycle.
    open func playOnce(completion: CompletionCallback? = nil) {
        play(loopMode: .once, completion: completion)
    }

    /// Plays the animation of the image.
    /// - Parameter amount: The amount of animation repetitions.
    /// - Parameter image: The callback handler called at the completion play cycle.
    open func playRepeat(amount: Int, completion: CompletionCallback? = nil) {
        play(loopMode: .repeat(amount: amount), completion: completion)
    }

    /// Plays the animation of the image.
    /// - Parameter image: The callback handler called at the completion play cycle.
    open func playIndefinitely(completion: CompletionCallback? = nil) {
        play(loopMode: .infinite, completion: completion)
    }

    /// Pauses the animation of the image.
    open func pause() {
        loopRenderer?.pause()
    }

    /// Stops the animation of the image.
    open func stop() {
        loopRenderer?.stop()
    }

    /// Clears the cache from rendered animation frames.
    open func clearCache() {
        loopRenderer?.clearCache()
    }

    /// Preheats the cache for each animation frame.
    open func preheatCache(completion: (() -> Void)? = nil) {
        loopRenderer?.preheatCache(completion: completion)
    }

    /// Tells the view that its window object changed.
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        autoplayAnimationIfNeeded()
    }

    /// Tells the view that its superview changed.
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        autoplayAnimationIfNeeded()
    }
}

private extension LoopView {

    func startObservingMemoryWarnings() {
        stopObservingMemoryWarnings()
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil, queue: nil) { [weak self] _ in
                self?.clearCache()
        }
    }

    func stopObservingMemoryWarnings() {
        if let memoryWarningObserver = memoryWarningObserver {
            NotificationCenter.default.removeObserver(memoryWarningObserver)
            self.memoryWarningObserver = nil
        }
    }

    func configureRenderer() {
        image = placeholderImage

        guard let loopImage = loopImage else {
            loopRenderer = nil
            return
        }

        loopRenderer = LoopRenderer(
            image: loopImage,
            playBackSpeedRate: playBackSpeedRate,
            viewLoopMode: loopMode,
            displayCallback: { [weak self] (frameIndex, cgImage) in
                guard let self = self, let loopImage = self.loopImage else {return }
                let image = cgImage.map { UIImage(cgImage: $0, scale: loopImage.scale, orientation: .up) }
                DispatchQueue.main.async {
                    self.image = image ?? self.placeholderImage
                }
                self.activityDelegate?.loopView(self, didDisplayImage: image, forFrameAtIndex: frameIndex)
            }
        )

        loopRenderer?.delegateCallback = { [weak self] event in
            self?.forward(event)
        }
    }

    private func forward(_ event: LoopRenderer.DelegateEvent) {
        guard let loopImage = loopImage else {
            return
        }

        switch event {
        case .didStartPlaying:
            delegate?.loopView(self, didStartPlayingImage: loopImage)
        case .didPausePlaying:
            delegate?.loopView(self, didPausePlayingImage: loopImage)
        case .didStopPlaying:
            delegate?.loopView(self, didStopPlayingImage: loopImage)
            completion?(false)
            completion = nil
        case let .didCompletePlaying(loopMode):
            delegate?.loopView(self, didFinishPlayingImage: loopImage, loopMode: loopMode)
            completion?(true)
            completion = nil

            if loopImage.isAnimation && completionBehavior == .stop {
                stop()
            } else {
                pause()
            }
        case let .didRenderFrame(index, fromCache):
            activityDelegate?.loopView(self, didRenderFrameAtIndex: index, fromCache: fromCache)
        }
    }

    func autoplayAnimationIfNeeded() {
        guard autoPlay, image != nil, superview != nil, window != nil else {
            return
        }

        play()
    }
}
