import Foundation

final class CodecRegistry {
    static let shared = CodecRegistry()

    private(set) var registeredCodecs: [Codec.Type] = {
        var codecs: [Codec.Type] = [
            GIFCodec.self,
            APNGCodec.self
        ]
        if #available(iOS 13, *) {
            codecs.append(HEICCodec.self)
        }
        return codecs
    }()

    func register(codec: Codec.Type) {
        registeredCodecs.append(codec)
    }
}
