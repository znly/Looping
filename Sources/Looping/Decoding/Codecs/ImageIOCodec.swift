import Foundation

import ImageIO

protocol ImageIOCodecProperties {
    static var dictionaryKey: CFString { get }
    static var loopCountKey: CFString { get }
    static var unclampedDelayTimeKey: CFString { get }
    static var delayTimeKey: CFString { get }

    static func canDecode(data: Data) -> Bool
}

final class ImageIOCodec<CodecProperties: ImageIOCodecProperties>: Codec {
    private let data: Data
    private let source: CGImageSource

    let isAnimation: Bool
    let hasAlpha: Bool
    let canvasWidth: Int
    let canvasHeight: Int
    let loopCount: Int
    let frameCount: Int
    let framesHasAlpha: [Bool]
    let framesDuration: [TimeInterval]
    let animationDuration: TimeInterval
    let colorspace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    let areFramesIndependent = true

    static func canDecode(data: Data) -> Bool {
        return CodecProperties.canDecode(data: data)
    }

    init(data: Data) throws {
        self.data = data

        source = try ImageIOCodec.generateSource(data: data)
        frameCount = ImageIOCodec.getFrameCount(source: source)
        isAnimation = frameCount > 1
        framesHasAlpha = ImageIOCodec.getFramesAlpha(source: source, frameCount: frameCount)
        hasAlpha = framesHasAlpha.firstIndex(of: true) != nil
        framesDuration = ImageIOCodec.getFramesDuration(source: source, frameCount: frameCount)
        animationDuration = framesDuration.reduce(0, +)

        let properties = ImageIOCodec.getProperties(source: source)
        (canvasWidth, canvasHeight) = try ImageIOCodec.getCanvasSize(properties: properties, source: source)
        loopCount = ImageIOCodec.getLoopCount(properties: properties)
    }

    func frame(at index: Int) throws -> Frame {
        let index = index % frameCount

        guard index >= 0 else {
            throw CodecError.frameIndexOutOfBounds(index)
        }

        return Frame(
            index: index,
            offsetX: .zero,
            offsetY: .zero,
            duration: framesDuration[index],
            width: canvasWidth,
            height: canvasHeight,
            hasAlpha: framesHasAlpha[index],
            disposeToBackgroundColor: false,
            blendWithPreviousFrame: false
        )
    }

    func decode(at index: Int) throws -> CGImage? {
        let index = index % frameCount

        guard index >= 0 else {
            throw CodecError.frameIndexOutOfBounds(index)
        }

        return CGImageSourceCreateImageAtIndex(source, index, nil)
    }
}

private extension ImageIOCodec {

    static func generateSource(data: Data) throws -> CGImageSource {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw CodecError.invalidData
        }

        return source
    }

    static func getProperties(source: CGImageSource) -> NSDictionary? {
        guard let imageProperties = CGImageSourceCopyProperties(source, nil).map({ NSDictionary(dictionary: $0) }),
            let properties = imageProperties[CodecProperties.dictionaryKey] as? NSDictionary else {
                return nil
        }

        return properties
    }

    private static func getCanvasSize(source: CGImageSource) throws -> (Int, Int) {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil).map({ NSDictionary(dictionary: $0) }),
            let width = (properties[kCGImagePropertyPixelWidth] as? NSNumber)?.intValue,
            let height = (properties[kCGImagePropertyPixelHeight] as? NSNumber)?.intValue else {
                throw CodecError.invalidData
        }

        return (width, height)
    }

    static func getCanvasSize(properties: NSDictionary?, source: CGImageSource) throws -> (Int, Int) {
        if let properties = properties {
            if let width = (properties[kCGImagePropertyPixelWidth] as? NSNumber)?.intValue,
                let height = (properties[kCGImagePropertyPixelHeight] as? NSNumber)?.intValue {

                return (width, height)
            }
        }

        return try getCanvasSize(source: source)
    }

    static func getLoopCount(properties: NSDictionary?) -> Int {
        return (properties?[CodecProperties.loopCountKey] as? NSNumber)?.intValue ?? 0
    }

    static func getFrameCount(source: CGImageSource) -> Int {
        return Int(CGImageSourceGetCount(source))
    }

    private static func getFrameDuration(source: CGImageSource, at index: Int) -> TimeInterval {
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil).map({ NSDictionary(dictionary: $0) }),
            let properties = imageProperties[CodecProperties.dictionaryKey] as? NSDictionary else {
                return ImageIOCodec.defaultFrameDuration
        }

        let frameDuration = (properties[CodecProperties.unclampedDelayTimeKey] as? NSNumber)?.doubleValue
            ?? (properties[CodecProperties.delayTimeKey] as? NSNumber)?.doubleValue
            ?? ImageIOCodec.defaultFrameDuration

        if frameDuration < 0.011 {
            return ImageIOCodec.defaultFrameDuration
        }

        return frameDuration
    }

    static func getFramesDuration(source: CGImageSource, frameCount: Int) -> [TimeInterval] {
        return (0..<frameCount)
            .map { getFrameDuration(source: source, at: $0) }
    }

    private static func getFrameAlpha(source: CGImageSource, at index: Int) -> Bool {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil).map({ NSDictionary(dictionary: $0) }) else {
            return false
        }

        return (properties[kCGImagePropertyHasAlpha] as? NSNumber)?.boolValue ?? false
    }

    static func getFramesAlpha(source: CGImageSource, frameCount: Int) -> [Bool] {
        return (0..<frameCount)
            .map { getFrameAlpha(source: source, at: $0) }
    }
}
