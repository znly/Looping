import Foundation

import WebPImage

enum LoopMode: Int, CustomStringConvertible, CaseIterable {
    case `default` = -1
    case infinite = 0
    case one = 1
    case two = 2
    case five = 5
    case ten = 10

    var value: AnimatedImage.LoopMode? {
        switch self {
        case .default: return nil
        default: return Image.LoopMode(amount: rawValue)
        }
    }

    public var description: String {
        switch self {
        case .default: return "⃠"
        case .infinite: return "∞"
        default: return String(rawValue)
        }
    }
}
