import Foundation

import class ImageIO.CGContext
import class ImageIO.CGImage
import class ImageIO.CGContext
import struct ImageIO.CGSize
import struct ImageIO.CGRect
import struct ImageIO.CGBitmapInfo
import func ImageIO.CGColorSpaceCreateDeviceRGB
import enum ImageIO.CGImageAlphaInfo

extension LoopImage {

    func createCanvasContext(from image: CGImage? = nil) -> CGContext? {
        let bitmapInfo: CGBitmapInfo = hasAlpha
            ? [CGBitmapInfo.byteOrder32Big, CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)]
            : [CGBitmapInfo.byteOrder32Big, CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)]

        guard let image = image else {
            return CGContext(
                data: nil,
                width: Int(canvasSize.width),
                height: Int(canvasSize.height),
                bitsPerComponent: 8,
                bytesPerRow: .zero,
                space: colorspace,
                bitmapInfo: bitmapInfo.rawValue
            )
        }

        let context = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: image.bytesPerRow,
            space: colorspace,
            bitmapInfo: bitmapInfo.rawValue
        )

        context?.draw(image, in: CGRect(origin: .zero, size: CGSize(width: image.width, height: image.height)))

        return context
    }
}
