import Foundation
import CoreGraphics

enum WebPImageAsset: String, CaseIterable, CustomStringConvertible {
    case none

    // Animated
    case banana
    case bladerunner
    case contact
    case genevadrive
    case niancat
    case rubixcube
    case steamengine
    case worldcup

    static let animated: [WebPImageAsset] = [
        none, banana, bladerunner, contact, genevadrive, niancat, rubixcube, steamengine, worldcup
    ]

    // Static
    case canyon
    case colors
    case dices
    case flamethrower
    case flower
    case google
    case rapids
    case riverbank
    case tree
    case tux

    static let `static`: [WebPImageAsset] = [
        none, canyon, dices, flamethrower, flower, google, rapids, riverbank, tree, tux
    ]

    public var description: String {
        switch self {
        case .none: return "---"
        case .bladerunner: return "Blade runner"
        case .genevadrive: return "Geneva drive"
        case .steamengine: return "Steam engine"
        default: return rawValue.capitalized
        }
    }

    public var name: String? {
        switch self {
        case .none: return nil
        case .genevadrive, .rubixcube, .steamengine: return rawValue
        case .banana: return rawValue + "@3x"
        default: return rawValue + "@2x"
        }
    }
}
