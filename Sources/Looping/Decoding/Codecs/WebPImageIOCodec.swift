import Foundation

import ImageIO

@available(iOS 14, *)
typealias WebPImageIOCodec = ImageIOCodec<WebPImageIOCodecProperties>

@available(iOS 14, *)
enum WebPImageIOCodecProperties: ImageIOCodecProperties {
    private enum DataHeader {
        static let length = 12
        static let prefix = "RIFF"
        static let suffix = "WEBP"
    }

    static var dictionaryKey = kCGImagePropertyWebPDictionary
    static var loopCountKey = kCGImagePropertyWebPLoopCount
    static var unclampedDelayTimeKey = kCGImagePropertyWebPUnclampedDelayTime
    static var delayTimeKey = kCGImagePropertyWebPDelayTime
    static var widthKey = kCGImagePropertyWebPCanvasPixelWidth
    static var heightKey = kCGImagePropertyWebPCanvasPixelHeight

    static func canDecode(data: Data) -> Bool {
        guard data.count >= DataHeader.length,
              data[0] == 0x52,
              let header = String(bytes: data[0..<12], encoding: .ascii),
              header.hasPrefix(DataHeader.prefix),
              header.hasSuffix(DataHeader.suffix) else {
            return false
        }

        return true
    }
}
