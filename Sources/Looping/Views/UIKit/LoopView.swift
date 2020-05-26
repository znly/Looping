import UIKit

/// An object that displays a static or an animated image in your interface.
@IBDesignable open class LoopView: UIView {

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
    open var image: LoopImage? {
        set {
            stop()
            loopLayer.image = newValue
            toggleAnimationIfNeeded()
            invalidateIntrinsicContentSize()
            frame.size = intrinsicContentSize
            setNeedsLayout()
        } get {
            return loopLayer.image
        }
    }

    /// The scale factor of the display.
    /// - Important: Strictly positive.
    @IBInspectable open var displayScale: CGFloat = UIScreen.main.scale {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    /// A flag used to determine how a view lays out its content when its bounds change.
    @IBInspectable open override var contentMode: ContentMode {
        didSet {
            setNeedsLayout()
        }
    }

    /// A flag to determine if the view should start playing images automatically.
    ///
    /// This property is set to `true` by default.
    @IBInspectable open var autoPlay = true {
        didSet {
            toggleAnimationIfNeeded()
        }
    }

    /// A flag to determine if the view generate a thumbnail image fitted to the frame size.
    /// - Important: Can be CPU intensive.
    @IBInspectable open var generateThumbnail = false {
        didSet {
            setNeedsLayout()
        }
    }

    /// Levels of interpolation quality for rendering the thumbnail image.
    @IBInspectable open var interpolationQuality: CGInterpolationQuality {
        set {
            loopLayer.interpolationQuality = newValue
        } get {
            return loopLayer.interpolationQuality
        }
    }

    /// A flag to determine if the frames generated should be cached.
    @IBInspectable open var useCache: Bool {
        set {
            loopLayer.useCache = newValue
        } get {
            return loopLayer.useCache
        }
    }

    /// The speed factor at which the animation should be played (limited by the display refresh rate).
    /// - Important: Non-negative.
    @IBInspectable open var playBackSpeedRate: Double {
        set {
            loopLayer.playBackSpeedRate = newValue
        } get {
            return loopLayer.playBackSpeedRate
        }
    }

    /// The amount of time the animation should play, overriding the amount set in the image.
    open var loopMode: LoopImage.LoopMode? {
        set {
            loopLayer.viewLoopMode = newValue
            toggleAnimationIfNeeded()
        } get {
            return loopLayer.viewLoopMode
        }
    }

    /// The behavior following the completion of the play cycle.
    open var completionBehavior: CompletionBehavior = .stop

    /// Returns true if the image animation is playing.
    open var isPlaying: Bool {
        return loopLayer.isPlaying
    }

    private var loopLayer: LoopLayer {
        return layer as! LoopLayer
    }

    /// Returns the class used to create the layer for instances of this class.
    override public static var layerClass: AnyClass {
        return LoopLayer.self
    }

    /// The natural size for the receiving view, considering only properties of the view itself.
    override open var intrinsicContentSize: CGSize {
        guard let image = image else {
            return .zero
        }

        return image.size
    }

    /// Returns an loop view initialized with the specified image.
    /// - Parameter image: The initial image to display in the loop view.
    public convenience init(image: LoopImage?) {
        self.init()

        self.image = image
    }

    /// Initializes and returns a newly allocated view object with the specified frame rectangle.
    /// - Parameter frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    /// Initializes and returns a newly allocated view object with the specified coder.
    /// - Parameter coder: The coder for the view.
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    deinit {
        NotificationCenter.default.removeObserver(loopLayer, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        NotificationCenter.default.removeObserver(loopLayer, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    /// Plays the animation of the image.
    /// - Parameters:
    ///   - loopMode: The amount of time the animation should play or left to nil to keep current behavior.
    ///   - useCache: A flag to determine if the frames generated should be cached or left to nil to keep current behavior.
    ///   - completion: The callback handler called at the completion play cycle.
    open func play(loopMode: LoopImage.LoopMode? = nil, useCache: Bool? = nil, completion: CompletionCallback? = nil) {
        if let loopMode = loopMode {
            self.loopMode = loopMode
        }

        if let useCache = useCache {
            self.useCache = useCache
        }

        if let completion = completion {
            self.completion = completion
        }

        loopLayer.play()
    }

    /// Plays the animation of the image.
    /// - Parameter completion: The callback handler called at the completion play cycle.
    open func playOnce(completion: CompletionCallback? = nil) {
        play(loopMode: .once, useCache: false, completion: completion)
    }

    /// Plays the animation of the image.
    /// - Parameter amount: The amount of animation repetitions.
    /// - Parameter image: The callback handler called at the completion play cycle.
    open func playRepeat(amount: Int, completion: CompletionCallback? = nil) {
        play(loopMode: .repeat(amount: amount), useCache: true, completion: completion)
    }

    /// Plays the animation of the image.
    /// - Parameter image: The callback handler called at the completion play cycle.
    open func playIndefinitely(completion: CompletionCallback? = nil) {
        play(loopMode: .infinite, useCache: true, completion: completion)
    }

    /// Pauses the animation of the image.
    open func pause() {
        loopLayer.pause()
    }

    /// Stops the animation of the image.
    open func stop() {
        loopLayer.stop()
    }

    /// Lays out subviews.
    override open func layoutSubviews() {
        super.layoutSubviews()

        let canvasFrame = computeCanvasFrame()

        loopLayer.canvasFrame = canvasFrame
        loopLayer.thumbnailSize = generateThumbnail
            ? CGSize(width: canvasFrame.width * displayScale, height: canvasFrame.height * displayScale)
            : nil
    }

    /// Tells the view that its window object changed.
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        toggleAnimationIfNeeded()
    }

    /// Tells the view that its superview changed.
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        toggleAnimationIfNeeded()
    }
}

private extension LoopView {

    func configure() {
        NotificationCenter.default.addObserver(
            loopLayer,
            selector: #selector(LoopLayer.clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            loopLayer,
            selector: #selector(LoopLayer.clearCache),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        loopLayer.delegateCallback = { [weak self] event in
            self?.forward(event)
        }

        backgroundColor = .clear
    }

    private func forward(_ event: LoopLayer.DelegateEvent) {
        guard let image = image else {
            return
        }

        switch event {
        case .didStartPlaying:
            delegate?.loopView(self, didStartPlayingImage: image)
        case .didPausePlaying:
            delegate?.loopView(self, didPausePlayingImage: image)
        case .didStopPlaying:
            delegate?.loopView(self, didStopPlayingImage: image)
            completion?(false)
            completion = nil
        case let .didCompletePlaying(loopMode):
            delegate?.loopView(self, didFinishPlayingImage: image, loopMode: loopMode)
            completion?(true)
            completion = nil

            if image.isAnimation && completionBehavior == .stop {
                stop()
            } else {
                pause()
            }
        case let .didRenderFrame(index, fromCache):
            activityDelegate?.loopView(self, didRenderFrameAtIndex: index, fromCache: fromCache)
        case let .didDisplayImage(image):
            activityDelegate?.loopView(self, didDisplay: image)
        }
    }

    func toggleAnimationIfNeeded() {
        guard image != nil, superview != nil, window != nil else {
            stop()
            return
        }

        if autoPlay {
            play()
        }
    }

    private func computeCanvasSize(image: LoopImage) -> CGSize {
        guard image.size != .zero else {
            return .zero
        }

        let widthRatio = bounds.width / image.size.width
        let heightRatio = bounds.height / image.size.height

        switch contentMode {
        case .scaleAspectFit:
            let minRatio = min(widthRatio, heightRatio)
            return CGSize(width: minRatio * image.size.width, height: minRatio * image.size.height)
        case .scaleAspectFill:
            let maxRatio = max(widthRatio, heightRatio)
            return CGSize(width: maxRatio * image.size.width, height: maxRatio * image.size.height)
        case .scaleToFill:
            return bounds.size
        default:
            return image.size
        }
    }

    private func computeCanvasOrigin(image: LoopImage, size: CGSize) -> CGPoint {
        let top: CGFloat = .zero
        let left: CGFloat = .zero
        let right = bounds.width - CGFloat(size.width)
        let centerX = right * 0.5
        let bottom = bounds.height - CGFloat(size.height)
        let centerY = bottom * 0.5

        switch contentMode {
        case .topLeft:
            return .zero
        case .top:
            return CGPoint(x: centerX, y: top)
        case .topRight:
            return CGPoint(x: right, y: top)
        case .left:
            return CGPoint(x: left, y: centerY)
        case .right:
            return CGPoint(x: right, y: centerY)
        case .bottomLeft:
            return CGPoint(x: left, y: bottom)
        case .bottom:
            return CGPoint(x: centerX, y: bottom)
        case .bottomRight:
            return CGPoint(x: right, y: bottom)
        default:
            return CGPoint(x: centerX, y: centerY)
        }
    }

    func computeCanvasFrame() -> CGRect {
        guard let image = image else {
            return .zero
        }

        let size = computeCanvasSize(image: image)
        let origin = computeCanvasOrigin(image: image, size: size)

        return CGRect(
            origin: origin,
            size: size
        ).integral
    }
}
