import Foundation

extension Data {

    func codec() -> Codec.Type? {
        return CodecRegistry.shared.registeredCodecs.first(where: {
            $0.canDecode(data: self)
        })
    }
}
