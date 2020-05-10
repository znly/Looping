import Foundation
import CoreGraphics

extension CGInterpolationQuality {

    public var description: String {
        switch self {
        case .default: return "default"
        case .none: return "⃠"
        case .low: return "low"
        case .medium: return "med"
        case .high: return "hi"
        @unknown default: fatalError()
        }
    }
}
