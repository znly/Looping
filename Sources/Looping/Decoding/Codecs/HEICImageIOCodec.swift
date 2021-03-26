import Foundation

import ImageIO

@available(iOS 13, *)
typealias HEICImageIOCodec = ImageIOCodec<HEICImageIOCodecProperties>

@available(iOS 13, *)
enum HEICImageIOCodecProperties: ImageIOCodecProperties {
    private enum DataHeader {
        static let length = 12
        static let flags = Set(["mif1", "msf1", "heic", "heix", "hevc", "hevx"])
    }

    static var dictionaryKey = kCGImagePropertyHEICSDictionary
    static var loopCountKey = kCGImagePropertyHEICSLoopCount
    static var unclampedDelayTimeKey = kCGImagePropertyHEICSUnclampedDelayTime
    static var delayTimeKey = kCGImagePropertyHEICSDelayTime
    static var widthKey = kCGImagePropertyHEICSCanvasPixelWidth
    static var heightKey = kCGImagePropertyHEICSCanvasPixelHeight

    static func canDecode(data: Data) -> Bool {
        guard data.count >= DataHeader.length, data[0] == 0x00 else { return false }
        return String(data: data[8..<12], encoding: .ascii)
            .map { DataHeader.flags.contains($0) } ?? false
    }
}
