import UIKit

extension UIView.ContentMode {

    public var description: String {
        switch self {
        case .bottom: return "⎵"
        case .bottomLeft: return "⌞"
        case .bottomRight: return "⌟"
        case .center: return "☩"
        case .left: return "["
        case .right: return "]"
        case .scaleAspectFill: return "𝗖"
        case .scaleAspectFit: return "𝗰"
        case .scaleToFill: return "𝙲"
        case .top: return "⎴"
        case .topLeft: return "⌜"
        case .topRight: return "⌝"
        default: fatalError()
        }
    }
}
