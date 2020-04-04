import Foundation

import class CoreGraphics.CGImage
import class CoreGraphics.CGContext
import struct CoreGraphics.CGRect
import struct CoreGraphics.CGSize
import struct CoreGraphics.CGBitmapInfo
import func CoreGraphics.CGColorSpaceCreateDeviceRGB
import enum CoreGraphics.CGImageAlphaInfo

extension WebPImage {

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
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: bitmapInfo.rawValue
            )
        }

        let context = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: image.bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo.rawValue
        )

        context?.draw(image, in: CGRect(origin: .zero, size: CGSize(width: image.width, height: image.height)))

        return context
    }
}
