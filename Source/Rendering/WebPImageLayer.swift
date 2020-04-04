import Foundation

import class QuartzCore.CALayer
import class QuartzCore.CATransaction
import class CoreGraphics.CGContext
import class CoreGraphics.CGImage
import struct CoreGraphics.CGRect
import struct CoreGraphics.CGSize
import struct CoreGraphics.CGFloat
import enum CoreGraphics.CGInterpolationQuality
import func CoreGraphics.CGColorSpaceCreateDeviceRGB

private extension CATransaction {

    static func withDisabledActions<T>(_ body: () throws -> T) rethrows -> T {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer { CATransaction.commit() }
        return try body()
    }
}

private extension CGImage {

    func scaled(to size: CGSize, interpolationQuality: CGInterpolationQuality) -> CGImage? {
        guard size.width != CGFloat(width) || size.height != CGFloat(height) else {
            return self
        }

        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: .zero,
                                space: colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: bitmapInfo.rawValue)
        context?.interpolationQuality = interpolationQuality
        context?.draw(self, in: CGRect(origin: .zero, size: size).integral)

        return context?.makeImage()
    }
}

final class WebPImageLayer: CALayer {
    private let displayQueue = DispatchQueue(label: "webPImageLayer:display", qos: .userInteractive)
    private let canvasLayer = CALayer()
    private var imageRenderer: WebPImageRenderer?

    enum DelegateEvent {
        case didStartPlaying, didPausePlaying, didStopPlaying, didCompletePlaying(WebPImage.LoopMode)
        case didRenderFrame(Int), didDisplayImage(CGImage?)
    }

    var delegateCallback: ((DelegateEvent) -> Void)?

    var canvasFrame: CGRect {
        set {
            guard newValue != canvasFrame else { return }
            CATransaction.withDisabledActions {
                canvasLayer.frame = newValue
            }
        } get {
            return canvasLayer.frame
        }
    }

    var thumbnailSize: CGSize? {
        didSet {
            guard thumbnailSize != oldValue else { return }
            setNeedsDisplay()
        }
    }

    var interpolationQuality: CGInterpolationQuality = .medium {
        didSet {
            guard thumbnailSize != nil, interpolationQuality != oldValue else { return }
            setNeedsDisplay()
        }
    }

    var useCache: Bool = true {
        didSet {
            imageRenderer?.useCache = useCache
        }
    }

    var playbackSpeed: Double = 1 {
        didSet {
            imageRenderer?.playbackSpeed = playbackSpeed
        }
    }

    var viewLoopMode: WebPImage.LoopMode? {
        didSet {
            imageRenderer?.viewLoopMode = viewLoopMode
        }
    }

    var image: WebPImage? = nil {
        willSet {
            stop()
        } didSet {
            resetImage()
        }
    }

    var isPlaying: Bool {
        return imageRenderer?.isRendering == true
    }

    override init() {
        super.init()
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    override init(layer: Any) {
        if let layer = layer as? WebPImageLayer {
            thumbnailSize = layer.thumbnailSize
            playbackSpeed = layer.playbackSpeed
            image = layer.image
            imageRenderer = layer.imageRenderer
        }

        super.init(layer: layer)

        if let layer = layer as? WebPImageLayer {
            canvasFrame = layer.canvasFrame
            contents = layer.contents
        }
    }

    override func display() {
        super.display()

        // Copy (on write) on the stack to ensure thread safety if mutated during display
        let thumbnailSize = self.thumbnailSize
        let interpolationQuality = self.interpolationQuality

        displayCanvas(
            thumbnailSize: thumbnailSize,
            interpolationQuality: interpolationQuality
        )
    }

    @discardableResult func play() -> Bool {
        return imageRenderer?.start() ?? false
    }

    @discardableResult func pause() -> Bool {
        return imageRenderer?.pause() ?? false
    }

    @discardableResult func stop() -> Bool {
        return imageRenderer?.stop() ?? false
    }

    @objc func clearCache() {
        imageRenderer?.clearCache()
    }
}

private extension WebPImageLayer {

    func displayCanvas(thumbnailSize: CGSize?, interpolationQuality: CGInterpolationQuality) {
        var image = imageRenderer?.renderedImage

        displayQueue.async { [weak self] in
            if let originalImage = image, let thumbnailSize = thumbnailSize {
                image = originalImage.scaled(to: thumbnailSize, interpolationQuality: interpolationQuality) ?? originalImage
            }

            DispatchQueue.main.async {
                CATransaction.withDisabledActions {
                    self?.canvasLayer.contents = image
                }

                self?.delegateCallback?(.didDisplayImage(image))
            }
        }
    }

    private func forward(_ event: WebPImageRenderer.DelegateEvent) {
        switch event {
        case .didStartPlaying:
            delegateCallback?(.didStartPlaying)
        case .didPausePlaying:
            delegateCallback?(.didPausePlaying)
        case .didStopPlaying:
            delegateCallback?(.didStopPlaying)
        case let .didCompletePlaying(loopMode):
            delegateCallback?(.didCompletePlaying(loopMode))
        case let .didRenderFrame(index):
            delegateCallback?(.didRenderFrame(index))
        }
    }

    func resetImage() {
        CATransaction.withDisabledActions {
            contentsScale = image?.scale ?? 1.0
            canvasLayer.contents = nil
        }

        if let image = image {
            imageRenderer = WebPImageRenderer(
                image: image,
                useCache: useCache,
                playbackSpeed: playbackSpeed,
                viewLoopMode: viewLoopMode,
                displayCallback: { [weak self] in
                    self?.setNeedsDisplay()
                }
            )

            imageRenderer?.delegateCallback = { [weak self] event in
                self?.forward(event)
            }
        } else {
            imageRenderer = nil
        }
    }

    func configure() {
        addSublayer(canvasLayer)
    }
}
