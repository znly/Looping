import Foundation

extension Frame: CustomDebugStringConvertible {

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        let information: [String: String] = [
            "size": "{\(width), \(height)}",
            "offset": "{\(offsetX), \(offsetY)}",
            "duration": "\(Int(duration * 1000))ms",
            "index": String(index),
            "hasAlpha": "\(hasAlpha)",
            "disposeToBackgroundColor": String(disposeToBackgroundColor),
            "blendWithPreviousFrame": String(blendWithPreviousFrame)
        ]
        let description = information
            .map { "\($0.key): \($0.value)" }
            .sorted()
            .joined(separator: ", ")

        return "Frame(\(description))"
    }
}
