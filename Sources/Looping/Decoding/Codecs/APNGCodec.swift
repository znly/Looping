import Foundation

import ImageIO

typealias APNGCodec = ImageIOCodec<APNGCodecProperties>

enum APNGCodecProperties: ImageIOCodecProperties {
    static var dictionaryKey = kCGImagePropertyPNGDictionary
    static var loopCountKey = kCGImagePropertyAPNGLoopCount
    static var unclampedDelayTimeKey = kCGImagePropertyAPNGUnclampedDelayTime
    static var delayTimeKey = kCGImagePropertyAPNGDelayTime
    @available(iOS 13, *) static var widthKey = kCGImagePropertyAPNGCanvasPixelWidth
    @available(iOS 13, *) static var heightKey = kCGImagePropertyAPNGCanvasPixelHeight

    static func canDecode(data: Data) -> Bool {
        return !data.isEmpty && data[0] == 0x89
    }
}
