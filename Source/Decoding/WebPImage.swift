import Foundation

import class CoreGraphics.CGImage
import class CoreGraphics.CGColorSpace
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGSize
import struct CoreGraphics.CGRect

/// Immutable representation of a webp image.
///
/// You can use image objects in several different ways:
/// - Assign an image to a WebPImageView object to display the image in your interface.
/// - Generate a UIImage or CGImage from a specific frame.
public struct WebPImage {

    /// Default scale value for an image.
    public static let defaultScale: CGFloat = 1

    private let decoder: WebPDecoder

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
        return decoder.isAnimation
    }

    /// The number of frames contained in the image.
    public var frameCount: Int {
        return decoder.frameCount
    }

    /// The cumulative duration of all the frames.
    public var duration: TimeInterval {
        return decoder.animationDuration
    }

    /// The individual duration of each frame.
    public var frameDurations: [TimeInterval] {
        return decoder.frameDurations
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
        return decoder.hasAlpha
    }

    let uuid: String

    /// The colorspace to be use to render the image.
    var colorspace: CGColorSpace {
        return decoder.colorspace
    }

    /// Returns an image initialized with the specified webp data.
    /// - Parameters:
    ///   - data: The data of from a webp image.
    ///   - scale: The scale factor of the image.
    /// - Throws: WebPDecodingError
    public init(data: Data, scale: CGFloat = defaultScale) throws {
        guard scale > 0 else {
            throw WebPImageError.invalidScale
        }
        uuid = UUID().uuidString
        decoder = try WebPDecoder(data: data)
        self.scale = scale
        size = CGSize(width: CGFloat(decoder.canvasWidth) / scale, height: CGFloat(decoder.canvasHeight) / scale)
        canvasSize = CGSize(width: decoder.canvasWidth, height: decoder.canvasHeight)
        loopMode = LoopMode(amount: decoder.loopCount)
    }

    /// Returns an image initialized with the specified webp url.
    /// - Parameter url: The url of from a webp image.
    /// - Throws: WebPDecodingError
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

    /// Returns an image initialized with the specified webp image name and bundle.
    /// - Parameters:
    ///   - named: The name of the webp image asset.
    ///   - bundle: The bundle in which the image is contained.
    /// - Throws: WebPDecodingError
    public init(named name: String, bundle: Bundle = Bundle.main) throws {
        try self.init(url: bundle.url(forResource: name, withExtension: "webp")!)
    }

    /// Creates and returns a CGImage from the image at a specific frame.
    /// - Parameter frameIndex: The frame at which the image should be generated.
    /// - Returns: A CGImage object that contains a snapshot of the image at the given frame or NULL if the image is not created.
    public func cgImage(atFrame frameIndex: Int = 0) -> CGImage? {
        let frameIndex: Int = max(frameIndex % frameCount, 0)

        guard let context = createCanvasContext() else {
            return nil
        }

        var previousFrame: WebPImageFrame?
        for intermediaryIndex in 0...frameIndex {
            if let frame = try? decoder.frame(at: intermediaryIndex) {
                try? frame.render(in: context, colorspace: colorspace, previousFrame: previousFrame)
                previousFrame = frame
            }
        }

        return context.makeImage()
    }

    func frame(at index: Int) throws -> WebPImageFrame {
        return try decoder.frame(at: index)
    }
}
