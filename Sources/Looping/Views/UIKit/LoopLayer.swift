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

final class LoopLayer: CALayer {
    private let displayQueue = DispatchQueue(label: "loopLayer:display", qos: .userInteractive)
    private let canvasLayer = CALayer()
    private var loopRenderer: LoopRenderer?
    private var imageRendered: CGImage?

    enum DelegateEvent {
        case didStartPlaying, didPausePlaying, didStopPlaying, didCompletePlaying(LoopImage.LoopMode)
        case didRenderFrame(Int, Bool), didDisplayImage(CGImage?)
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

    var interpolationQuality: CGInterpolationQuality = .default {
        didSet {
            guard thumbnailSize != nil, interpolationQuality != oldValue else { return }
            setNeedsDisplay()
        }
    }

    var useCache: Bool = true {
        didSet {
            loopRenderer?.useCache = useCache
        }
    }

    var playBackSpeedRate: Double = 1 {
        didSet {
            loopRenderer?.playBackSpeedRate = playBackSpeedRate
        }
    }

    var viewLoopMode: LoopImage.LoopMode? {
        didSet {
            loopRenderer?.viewLoopMode = viewLoopMode
        }
    }

    var image: LoopImage? = nil {
        willSet {
            stop()
        } didSet {
            resetImage()
        }
    }

    var isPlaying: Bool {
        return loopRenderer?.isRendering == true
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
        if let layer = layer as? LoopLayer {
            thumbnailSize = layer.thumbnailSize
            playBackSpeedRate = layer.playBackSpeedRate
            image = layer.image
            loopRenderer = layer.loopRenderer
        }

        super.init(layer: layer)

        if let layer = layer as? LoopLayer {
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
        return loopRenderer?.start() ?? false
    }

    @discardableResult func pause() -> Bool {
        return loopRenderer?.pause() ?? false
    }

    @discardableResult func stop() -> Bool {
        return loopRenderer?.stop() ?? false
    }

    @objc func clearCache() {
        loopRenderer?.clearCache()
    }
}

private extension LoopLayer {

    func displayCanvas(thumbnailSize: CGSize?, interpolationQuality: CGInterpolationQuality) {
        displayQueue.async { [weak self] in
            var image = self?.imageRendered
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

    private func forward(_ event: LoopRenderer.DelegateEvent) {
        switch event {
        case .didStartPlaying:
            delegateCallback?(.didStartPlaying)
        case .didPausePlaying:
            delegateCallback?(.didPausePlaying)
        case .didStopPlaying:
            delegateCallback?(.didStopPlaying)
        case let .didCompletePlaying(loopMode):
            delegateCallback?(.didCompletePlaying(loopMode))
        case let .didRenderFrame(index, didUseCache):
            delegateCallback?(.didRenderFrame(index, didUseCache))
        }
    }

    func resetImage() {
        CATransaction.withDisabledActions {
            contentsScale = image?.scale ?? 1.0
            canvasLayer.contents = nil
        }

        if let image = image {
            loopRenderer = LoopRenderer(
                image: image,
                useCache: useCache,
                playBackSpeedRate: playBackSpeedRate,
                viewLoopMode: viewLoopMode,
                displayCallback: { [weak self] image in
                    self?.displayQueue.sync(flags: .barrier) {
                        self?.imageRendered = image
                    }
                    self?.setNeedsDisplay()
                }
            )

            loopRenderer?.delegateCallback = { [weak self] event in
                self?.forward(event)
            }
        } else {
            loopRenderer = nil
        }
    }

    func configure() {
        addSublayer(canvasLayer)
    }
}
