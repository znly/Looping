import Foundation

final class CodecRegistry {
    static let shared = CodecRegistry()

    private(set) var registeredCodecs: [Codec.Type] = {
        var codecs: [Codec.Type] = [
            GIFImageIOCodec.self,
            APNGImageIOCodec.self
        ]
        if #available(iOS 13, *) {
            codecs.append(HEICImageIOCodec.self)
        }
        if #available(iOS 14, *) {
            codecs.append(WebPImageIOCodec.self)
        }
        return codecs
    }()

    func register(codec: Codec.Type) {
        registeredCodecs.append(codec)
    }
}
