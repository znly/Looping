import Foundation

import struct ImageIO.CGFloat
import struct ImageIO.CGSize
import class ImageIO.CGImage
import class ImageIO.CGContext
import class ImageIO.CGColorSpace

/// Immutable representation of an animated image.
///
/// You can use image objects in several different ways:
/// - Assign an image to a Loop or LoopView object to display the image in your interface.
/// - Generate a UIImage or CGImage from a specific frame.
public struct LoopImage {

    /// Default scale value for an image.
    public static let defaultScale: CGFloat = 1

    private let codec: Codec

    /// Representation of the amount of time an image animation loops.
    public enum LoopMode {

        /// Loops an infinite amount of time.
        case infinite

        /// Loops only once.
        case once

        /// Loops a specific amount of time.
        case `repeat`(amount: Int)

        /// Translates the amount to a numeric value.
        public var amount: Int {
            switch self {
            case .infinite: return 0
            case .once: return 1
            case let .repeat(amount): return amount
            }
        }

        /// Translates a numeric value to a LoopMode.
        /// - Parameter amount: The amount of loops.
        public init(amount: Int) {
            switch amount {
            case 0: self = .infinite
            case 1: self = .once
            default: self  = .repeat(amount: amount)
            }
        }
    }

    /// A flag used to determine if the image is an animation.
    public var isAnimation: Bool {
        return codec.isAnimation
    }

    /// The number of frames contained in the image.
    public var frameCount: Int {
        return codec.frameCount
    }

    /// The cumulative duration of all the frames.
    public var duration: TimeInterval {
        return codec.animationDuration
    }

    /// The individual duration of each frame.
    public var framesDuration: [TimeInterval] {
        return codec.framesDuration
    }

    var preferredFramesPerSecond: Int {
        guard let shortestDelayTime = framesDuration.min() else {
            return 0
        }
        return Int(ceil(1 / shortestDelayTime))
    }

    /// The scale factor of the image.
    public let scale: CGFloat

    /// The size of the image.
    public let size: CGSize

    /// The size of the canvas on which the image is rendered.
    public let canvasSize: CGSize

    /// The number of times the image should animate before stopping.
    public let loopMode: LoopMode

    /// A flag used to determine if the image uses alpha.
    public var hasAlpha: Bool {
        return codec.hasAlpha
    }

    let uuid: String

    /// The colorspace to be use to render the image.
    var colorspace: CGColorSpace {
        return codec.colorspace
    }

    /// Returns an image initialized with the specified image data.
    /// - Parameters:
    ///   - data: The data of from an image.
    ///   - scale: The scale factor of the image.
    /// - Throws: LoopImageError, CodecError, WebPCodecError
    public init(data: Data, scale: CGFloat = defaultScale) throws {
        guard let codecType = data.codec() else {
            throw LoopImageError.noMatchingCodec
        }

        let scale = scale > 0 ? scale : 1

        uuid = UUID().uuidString
        codec = try codecType.init(data: data)
        self.scale = scale
        size = CGSize(width: CGFloat(codec.canvasWidth) / scale, height: CGFloat(codec.canvasHeight) / scale)
        canvasSize = CGSize(width: codec.canvasWidth, height: codec.canvasHeight)
        loopMode = LoopMode(amount: codec.loopCount)
    }

    /// Returns an image initialized with the specified image url.
    /// - Parameter url: The url of from an image.
    /// - Throws: DecodingError
    public init(url: URL) throws {
        let scale: CGFloat
        switch url.deletingPathExtension()
            .lastPathComponent
            .suffix(3) {
        case "@3x":
            scale = 3
        case "@2x":
            scale = 2
        default:
            scale = 1
        }

        try self.init(data: try Data(contentsOf: url), scale: scale)
    }

    /// Returns an image initialized with the specified an image name and bundle.
    /// - Parameters:
    ///   - named: The name of the image asset.
    ///   - bundle: The bundle in which the image is contained.
    /// - Throws: DecodingError
    public init(named name: String, bundle: Bundle = Bundle.main) throws {
        try self.init(url: bundle.url(forResource: name, withExtension: String())!)
    }

    /// Creates and returns a CGImage from the image at a specific frame.
    /// - Parameter frameIndex: The frame at which the image should be generated.
    /// - Returns: A CGImage object that contains a snapshot of the image at the given frame or NULL if the image is not created.
    public func cgImage(atFrame frameIndex: Int = 0) -> CGImage? {
        if codec.areFramesIndependent {
            return try? codec.decode(at: frameIndex)
        }

        let frameIndex: Int = max(frameIndex % frameCount, 0)

        guard let context = createCanvasContext() else {
            return nil
        }

        var previousFrame: Frame?
        for intermediaryIndex in 0...frameIndex {
            if let frame = try? codec.frame(at: intermediaryIndex) {
                render(frame: frame, in: context, withPreviousFrame: previousFrame)
                previousFrame = frame
            }
        }

        return context.makeImage()
    }

    func frame(at index: Int) throws -> Frame {
        return try codec.frame(at: index)
    }

    @discardableResult
    func render(frame: Frame, in canvasContext: CGContext, withPreviousFrame previousFrame: Frame?) -> CGImage? {
        let drawRect = frame.drawRect(in: canvasContext)

        if let previousFrame = previousFrame, previousFrame.disposeToBackgroundColor {
            canvasContext.clear(previousFrame.drawRect(in: canvasContext))
        }

        if !frame.blendWithPreviousFrame {
            canvasContext.clear(drawRect)
        }

        try? codec.decode(at: frame.index)
            .map { canvasContext.draw($0, in: drawRect) }

        return canvasContext.makeImage()
    }
}
