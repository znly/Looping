import Foundation

import class ImageIO.CGContext
import struct ImageIO.CGRect

extension Frame {

    func drawRect(in canvasContext: CGContext) -> CGRect {
        return CGRect(
            x: offsetX,
            y: canvasContext.height - height - offsetY,
            width: width,
            height: height
        ).integral
    }
}
