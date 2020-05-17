import Foundation

import Looping

public extension LoopImage {

    static func enableWebP() {
        WebPCodec.register()
    }
}
