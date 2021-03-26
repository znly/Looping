import Foundation

import ImageIO

typealias GIFImageIOCodec = ImageIOCodec<GIFImageIOCodecProperties>

enum GIFImageIOCodecProperties: ImageIOCodecProperties {
    static var dictionaryKey = kCGImagePropertyGIFDictionary
    static var loopCountKey = kCGImagePropertyGIFLoopCount
    static var unclampedDelayTimeKey = kCGImagePropertyGIFUnclampedDelayTime
    static var delayTimeKey = kCGImagePropertyGIFDelayTime
    @available(iOS 13, *) static var widthKey = kCGImagePropertyGIFCanvasPixelWidth
    @available(iOS 13, *) static var heightKey = kCGImagePropertyGIFCanvasPixelHeight

    static func canDecode(data: Data) -> Bool {
        return !data.isEmpty && data[0] == 0x47
    }
}
