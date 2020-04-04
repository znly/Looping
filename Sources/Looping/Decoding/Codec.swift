import Foundation

import class ImageIO.CGImage
import class ImageIO.CGColorSpace

/// Defines what information a Codec needs to expose and what actions it should handle.
public protocol Codec {

    /// Flag to determine if the image is animated (more than 1 frame).
    var isAnimation: Bool { get }

    /// Flag to determine if the image contains an alpha component.
    var hasAlpha: Bool { get }

    /// Drawing width of the image.
    var canvasWidth: Int { get }

    /// Drawing height of the image.
    var canvasHeight: Int { get }

    /// Number of times the animation should loop.
    var loopCount: Int { get }

    /// Total number of frames in the image.
    var frameCount: Int { get }

    /// Duration of each frames.
    var framesDuration: [TimeInterval] { get }

    /// Total duration of the animation.
    var animationDuration: TimeInterval { get }

    /// Colorspace used to draw the image frames.
    var colorspace: CGColorSpace { get }

    /// Flags specifying if frames are built incrementally from the previous ones or idenpendently.
    var areFramesIndependent: Bool { get }

    /// Registers the codec.
    static func register()

    /// Determines if the data can be decoded by the codec.
    /// - Parameter data: Data of the image.
    static func canDecode(data: Data) -> Bool

    /// Returns a codec initialized with the data of an image.
    /// - Parameter data: Data of the image.
    init(data: Data) throws

    /// Extracts the information of the frame at a given index.
    /// - Parameter index: Index of the frame.
    func frame(at index: Int) throws -> Frame

    /// Decodes a frame at a given index.
    /// - Parameter index: Index of the frame.
    func decode(at index: Int) throws -> CGImage?
}

extension Codec {

    /// Registers the codec.
    public static func register() {
        CodecRegistry.shared.register(codec: Self.self)
    }

    /// Default duration of a frame.
    public static var defaultFrameDuration: TimeInterval {
        return 0.1
    }
}
