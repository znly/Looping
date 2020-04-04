import Foundation

import class CoreGraphics.CGContext
import class CoreGraphics.CGImage

final class WebPImageRenderer {
    private let image: WebPImage
    private let displayCallback: () -> Void

    private lazy var cache = WebPImageFrameCache(image: image)
    private lazy var renderQueue = DispatchQueue(label: "webPRenderer:render:\(image.uuid)", qos: .userInteractive)
    private var canvasContext: CGContext?
    private var waitTime: Double = .zero
    private var frameIndex: Int?
    private var frameRendered: WebPImageFrame?
    private var imageRendered: CGImage?

    enum DelegateEvent {
        case didStartPlaying, didPausePlaying, didStopPlaying, didCompletePlaying(WebPImage.LoopMode)
        case didRenderFrame(Int)
    }

    var delegateCallback: ((DelegateEvent) -> Void)?

    var playbackSpeed: Double
    var viewLoopMode: WebPImage.LoopMode?
    var useCache: Bool {
        set {
            renderQueue.async(flags: .barrier) { [weak self] in
                self?.safeUseCache = newValue
            }
        } get {
            return renderQueue.sync {
                return safeUseCache
            }
        }
    }

    private var safeUseCache: Bool {
        didSet {
            if !safeUseCache {
                cache.clear()
            }
        }
    }

    private var loopMode: WebPImage.LoopMode {
        return image.isAnimation ? (viewLoopMode ?? image.loopMode) : image.loopMode
    }

    private lazy var displayLink = DisplayLink() { [weak self] elapsedTime in
        self?.renderFrameIfNeeded(elapsedTime: elapsedTime)
    }

    var renderedImage: CGImage? {
        return renderQueue.sync { return imageRendered }
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
        guard frameIndex != nil || isIteratingOverFrames else {
            return false
        }

        isIteratingOverFrames = false
        reset()
        delegateCallback?(.didStopPlaying)
        return true
    }

    init(image: WebPImage,
         useCache: Bool,
         playbackSpeed: Double,
         viewLoopMode: WebPImage.LoopMode?,
         displayCallback: @escaping () -> Void) {
        self.image = image
        self.playbackSpeed = playbackSpeed
        self.viewLoopMode = viewLoopMode
        self.displayCallback = displayCallback
        safeUseCache = useCache
    }

    func clearCache() {
        renderQueue.async(flags: .barrier) { [weak self] in
            self?.cache.clear()
        }
    }
}

extension WebPImageRenderer {

    private func checkForCompletion() -> Bool {
        guard let frameIndex = frameIndex else {
            return false
        }

        let loopAmount = loopMode.amount
        let loopedAmount = (frameIndex + 1) / image.frameCount

        if loopAmount != 0, loopedAmount >= loopAmount {
            return true
        }

        return false
    }

    private func frameIndexToRender(elapsedTime: TimeInterval) -> Int? {
        // Check if we should be iterating over frames
        guard isIteratingOverFrames, playbackSpeed > 0 else {
            return nil
        }

        // Stop iterating if needed
        guard !checkForCompletion() else {
            delegateCallback?(.didCompletePlaying(loopMode))
            return nil
        }

        // Check if can move to the next frame
        waitTime += elapsedTime

        if image.isAnimation, let frameIndex = frameIndex, frameIndex != 0 {
            let frameDuration = image.frameDurations[frameIndex % image.frameCount] / playbackSpeed

            // Check if we can move to the next frame
            guard waitTime >= frameDuration else {
                return nil
            }

            waitTime -= frameDuration
        } else {
            waitTime = 0
        }

        // Move to the next frame
        frameIndex = frameIndex?.advanced(by: 1) ?? 0

        return frameIndex
    }

    // Render the new frame
    private func renderFrame(at index: Int) {
        guard let frame = try? image.frame(at: index) else {
            return
        }

        let key = frame.cacheKey

        if safeUseCache, let canvasImage = cache.frame(forKey: key) {
            imageRendered = canvasImage
            canvasContext = image.createCanvasContext(from: canvasImage)
        } else {
            if canvasContext == nil {
                canvasContext = image.createCanvasContext()
            }

            guard let canvasContext = canvasContext else {
                return
            }

            try? frame.render(in: canvasContext, colorspace: image.colorspace, previousFrame: frameRendered)

            imageRendered = canvasContext.makeImage()

            if safeUseCache, let imageRendered = imageRendered {
                cache.set(frame: imageRendered, forKey: key)
            }
        }

        frameRendered = frame

        DispatchQueue.main.async { [weak self] in
            self?.displayCallback()
            self?.delegateCallback?(.didRenderFrame(index))
        }
    }

    func renderFrameIfNeeded(elapsedTime: TimeInterval) {
        guard let frameIndex = frameIndexToRender(elapsedTime: elapsedTime) else {
            return
        }

        renderQueue.async(flags: .barrier) { [weak self] in
            self?.renderFrame(at: frameIndex)
        }
    }

    func reset() {
        waitTime = .zero
        frameIndex = nil

        renderQueue.async(flags: .barrier) { [weak self] in
            self?.canvasContext = nil
            self?.frameRendered = nil
            self?.imageRendered = nil

            DispatchQueue.main.async {
                self?.displayCallback()
            }
        }
    }
}
