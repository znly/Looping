import Foundation

import ImageIO

typealias GIFCodec = ImageIOCodec<GIFCodecProperties>

enum GIFCodecProperties: ImageIOCodecProperties {
    static var dictionaryKey = kCGImagePropertyGIFDictionary
    static var loopCountKey = kCGImagePropertyGIFLoopCount
    static var unclampedDelayTimeKey = kCGImagePropertyGIFUnclampedDelayTime
    static var delayTimeKey = kCGImagePropertyGIFDelayTime

    static func canDecode(data: Data) -> Bool {
        return !data.isEmpty && data[0] == 0x47
    }
}
