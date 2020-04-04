import Foundation

import Looping

public extension LoopImage {

    /// Enables WebP support.
    ///
    /// This method should only be called once.
    static func enableWebP() {
        WebPCodec.register()
    }
}
