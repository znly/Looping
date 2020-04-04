import Foundation

extension WebPImage: CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        let information: [String: String] = [
            "scale": "\(scale)",
            "size": size.debugDescription,
            "canvasSize": canvasSize.debugDescription,
            "frames": String(frameCount),
            "duration": "\(Int(duration * 1000))ms",
            "loopMode": loopMode.debugDescription,
            "hasAlpha": "\(hasAlpha)"
        ]
        let description = information
            .map { "\($0.key): \($0.value)" }
            .sorted()
            .joined(separator: ", ")

        return "WebPImage(\(description))"
    }
}

extension WebPImage.LoopMode: CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        let value: String

        switch self {
        case .infinite:
            value = "infinite"
        case .once:
            value = "once"
        case let .repeat(amount):
            value = "repeat: \(amount)"
        }

        return "WebPImage.LoopMode(\(value))"
    }
}

extension WebPImage.LoopMode: CustomStringConvertible {

    /// A textual representation of this instance.
    public var description: String {
        switch self {
        case .infinite:
            return "infinite play"
        case .once:
            return "play once"
        case let .repeat(amount):
            return "repeat \(amount) times"
        }
    }
}

