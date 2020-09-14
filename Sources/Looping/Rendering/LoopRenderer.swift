import Foundation

import class ImageIO.CGContext
import class ImageIO.CGImage

final class LoopRenderer {
    private let image: LoopImage
    private let displayCallback: (Int?, CGImage?) -> Void

    private lazy var cache = FrameCache(image: image)
    private lazy var renderQueue = DispatchQueue(label: "looping.loopRenderer.\(image.uuid)", qos: .userInteractive)
    private var elapsedTimeRelativeToPlaybackSpeed: Double = .zero
    private var lastFrameIndexDisplayed: Int?

    enum DelegateEvent {
        case didStartPlaying, didPausePlaying, didStopPlaying, didCompletePlaying(LoopImage.LoopMode)
        case didRenderFrame(Int, Bool)
    }

    var delegateCallback: ((DelegateEvent) -> Void)?

    // Value can be negative if the animation is played in reverse.
    var playBackSpeedRate: Double {
        didSet {
            updateFrameRate()
        }
    }

    var viewLoopMode: LoopImage.LoopMode?

    private var loopMode: LoopImage.LoopMode {
        return image.isAnimation ? (viewLoopMode ?? image.loopMode) : image.loopMode
    }

    private lazy var displayLink = DisplayLink() { [weak self] elapsedTime in
        self?.displayFrameIfNeeded(elapsedTime: elapsedTime)
    }

    var isRendering: Bool {
        return isIteratingOverFrames
    }

    private var isIteratingOverFrames: Bool {
        set {
            displayLink.isPaused = !newValue
        } get {
            return !displayLink.isPaused
        }
    }

    init(image: LoopImage,
         playBackSpeedRate: Double,
         viewLoopMode: LoopImage.LoopMode?,
         displayCallback: @escaping (Int?, CGImage?) -> Void) {
        self.image = image
        self.playBackSpeedRate = playBackSpeedRate
        self.viewLoopMode = viewLoopMode
        self.displayCallback = displayCallback

        updateFrameRate()
    }

    func clearCache() {
        renderQueue.async { [weak self] in
            self?.cache.clear()
        }
    }

    func preheatCache(completion: (() -> Void)? = nil) {
        let upperBoundIndex = image.frameCount - 1
        let lowerBoundIndex = image.areFramesIndependent ? .zero : upperBoundIndex
        renderQueue.async { [weak self] in
            for index in lowerBoundIndex...upperBoundIndex {
                _ = self?.renderFrame(at: index)
            }
            completion?()
        }
    }

    @discardableResult func start() -> Bool {
        guard !isIteratingOverFrames else {
            return false
        }

        isIteratingOverFrames = true
        delegateCallback?(.didStartPlaying)
        return true
    }

    @discardableResult func pause() -> Bool {
        guard isIteratingOverFrames else {
            return false
        }

        isIteratingOverFrames = false
        delegateCallback?(.didPausePlaying)
        return true
    }

    @discardableResult func stop() -> Bool {
        isIteratingOverFrames = false
        reset()
        delegateCallback?(.didStopPlaying)
        return true
    }

    func seek(progress: Double, shouldResumePlaying: Bool) {
        pause()

        let frameIndex = moveToNextFrameToDisplay(progress: progress)

        displayFrame(at: frameIndex)

        if shouldResumePlaying {
            start()
        }
    }
}

private extension LoopRenderer {

    func updateFrameRate() {
        displayLink.preferredFramesPerSecond = Int(ceil(Double(image.preferredFramesPerSecond) * abs(playBackSpeedRate)))
    }

    func moveToNextFrameToDisplay(progress: Double) -> Int {
        let progress = min(max(progress, 0), 1)
        let lastFrameIndex = image.frameCount - 1
        let index = Int(Double(lastFrameIndex) * progress)

        if playBackSpeedRate < 0 {
            elapsedTimeRelativeToPlaybackSpeed = image.cumulativeFramesDuration[index] * -1
            return lastFrameIndex - index
        } else {
            elapsedTimeRelativeToPlaybackSpeed = image.cumulativeFramesDuration[index]
            return index
        }
    }

    private func hasAnimationReachedCompletion() -> Bool {
        guard image.isAnimation, image.duration > .zero else {
            return true
        }

        let loopAmount = Double(loopMode.amount)
        let loopedAmount = abs(elapsedTimeRelativeToPlaybackSpeed) / image.duration

        if loopAmount != .zero, loopedAmount >= loopAmount {
            return true
        }

        return false
    }

    private func moveToNextFrameToDisplay(elapsedTime: TimeInterval) -> (Int, Bool)? {
        guard isIteratingOverFrames, playBackSpeedRate != .zero else {
            return nil
        }

        guard image.isAnimation, image.duration > .zero else {
            return (.zero, true)
        }

        elapsedTimeRelativeToPlaybackSpeed += elapsedTime * playBackSpeedRate

        var playbackTimeRelativeToAnimationDuration = abs(elapsedTimeRelativeToPlaybackSpeed.truncatingRemainder(dividingBy: image.duration))

        if elapsedTimeRelativeToPlaybackSpeed < 0 {
            playbackTimeRelativeToAnimationDuration = image.duration - playbackTimeRelativeToAnimationDuration
        }

        let frameIndex: Int
        let isComplete = hasAnimationReachedCompletion()

        if isComplete {
            let lastFrameIndex = image.frameCount - 1
            frameIndex = elapsedTimeRelativeToPlaybackSpeed > 0 ? lastFrameIndex : .zero
        } else {
            frameIndex = image.cumulativeFramesDuration
                .firstIndex(
                    where: {
                        $0 > playbackTimeRelativeToAnimationDuration
                    }
                ) ?? .zero
        }

        return (frameIndex, isComplete)
    }

    private func renderFrame(at index: Int) -> CGImage? {
        // Based on what kind of image we're rendering and on what is in cache,
        // figure out from which frame we need to start rendering.
        var fromIntermediaryFrameIndex = index

        if !image.areFramesIndependent, index != .zero {
            fromIntermediaryFrameIndex = (0...index)
                .reversed()
                .first(where: {
                    guard let frame = try? image.frame(at: $0) else {
                        return false
                    }

                    return cache.frame(forKey: frame.cacheKey) != nil
                })
                ?? .zero
        }

        // Render the frame and any intermediary ones necessary.
        var renderedFrame: Frame?
        var renderedImage: CGImage?
        var canvasContext: CGContext?

        for frameIndex in fromIntermediaryFrameIndex...index {
            renderedImage = nil

            guard let frame = try? image.frame(at: frameIndex) else {
                break
            }

            let key = frame.cacheKey
            let didUseCache: Bool

            if let cachedImage = cache.frame(forKey: key) {
                didUseCache = true
                canvasContext = image.createCanvasContext(from: cachedImage)
                renderedImage = cachedImage
                renderedFrame = frame
            } else {
                didUseCache = false
                if canvasContext == nil {
                    canvasContext = image.createCanvasContext()
                }

                guard let canvasContext = canvasContext else {
                    return nil
                }

                renderedImage = image.render(frame: frame, in: canvasContext, withPreviousFrame: renderedFrame)
                renderedFrame = frame

                if let renderedImage = renderedImage {
                    cache.set(frame: renderedImage, forKey: key)
                }
            }

            DispatchQueue.main.async { [weak self] in
                self?.delegateCallback?(.didRenderFrame(frame.index, didUseCache))
            }
        }

        return renderedImage
    }

    func displayFrame(at index: Int) {
        guard lastFrameIndexDisplayed != index else {
            return
        }

        lastFrameIndexDisplayed = index
        renderQueue.async { [weak self] in
            guard let image = self?.renderFrame(at: index) else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.displayCallback(index, image)
            }
        }
    }

    func displayFrameIfNeeded(elapsedTime: TimeInterval) {
        guard let (frameIndex, isComplete) = moveToNextFrameToDisplay(elapsedTime: elapsedTime) else {
            return
        }

        displayFrame(at: frameIndex)

        if isComplete {
            delegateCallback?(.didCompletePlaying(loopMode))
        }
    }

    func reset() {
        elapsedTimeRelativeToPlaybackSpeed = .zero
        lastFrameIndexDisplayed = nil

        renderQueue.async { [weak self] in
            DispatchQueue.main.async {
                self?.displayCallback(nil, nil)
            }
        }
    }
}
