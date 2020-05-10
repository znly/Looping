import Foundation

import class UIKit.NSDataAsset
import class UIKit.UIScreen

extension LoopImage {

    /// Returns an image initialized from an asset catalog.
    /// - Parameters:
    ///   - named: The name of the image in the asset catalog.
    ///   - bundle: The bundle in which the image is contained.
    /// - Throws: DecodingError
    @available(iOS 9.0, *)
    public init(asset name: String, bundle: Bundle = Bundle.main) throws {
        guard let asset = NSDataAsset(name: name, bundle: bundle) else {
            throw DecodingError.invalidAsset
        }

        try self.init(data: asset.data, scale: UIScreen.main.scale)
    }
}
