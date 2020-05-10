import Foundation

import class ImageIO.CGImage
import class ImageIO.CGColorSpace

public protocol Codec {
    var isAnimation: Bool { get }
    var hasAlpha: Bool { get }
    var canvasWidth: Int { get }
    var canvasHeight: Int { get }
    var loopCount: Int { get }
    var frameCount: Int { get }
    var framesDuration: [TimeInterval] { get }
    var animationDuration: TimeInterval { get }
    var colorspace: CGColorSpace { get }
    var areFramesIndependent: Bool { get }

    static func register()
    static func canDecode(data: Data) -> Bool

    init(data: Data) throws
    func frame(at index: Int) throws -> Frame
    func decode(at index: Int) throws -> CGImage?
}

extension Codec {

    public static func register() {
        CodecRegistry.shared.register(codec: Self.self)
    }

    public static var defaultFrameDuration: TimeInterval {
        return 0.1
    }
}
