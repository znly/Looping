import Foundation

import class CoreGraphics.CGContext
import class CoreGraphics.CGColorSpace
import class CoreGraphics.CGDataProvider
import class CoreGraphics.CGImage
import struct CoreGraphics.CGRect
import struct CoreGraphics.CGBitmapInfo
import enum CoreGraphics.CGImageAlphaInfo

import WebP

struct WebPImageFrame {
    fileprivate let decoder: WebPDecoder

    let num: Int
    let offsetX: Int
    let offsetY: Int
    let duration: TimeInterval
    let width: Int
    let height: Int
    let hasAlpha: Bool
    let disposeToBackgroundColor: Bool
    let blendWithPreviousFrame: Bool

    var cacheKey: String {
        return String(num)
    }

    init(iterator: WebPIterator, decoder: WebPDecoder) {
        self.decoder = decoder

        num = Int(iterator.frame_num)
        offsetX = Int(iterator.x_offset)
        offsetY = Int(iterator.y_offset)
        duration = Double(iterator.duration) / 1000
        width = Int(iterator.width)
        height = Int(iterator.height)
        hasAlpha = iterator.has_alpha != 0
        disposeToBackgroundColor = iterator.dispose_method == WEBP_MUX_DISPOSE_BACKGROUND
        blendWithPreviousFrame = iterator.blend_method == WEBP_MUX_BLEND
    }

    func drawRect(in canvasContext: CGContext) -> CGRect {
        return CGRect(
            x: offsetX,
            y: canvasContext.height - height - offsetY,
            width: width,
            height: height
        ).integral
    }

    func render(in canvasContext: CGContext, colorspace: CGColorSpace, previousFrame: WebPImageFrame?) throws {
        let drawRect = self.drawRect(in: canvasContext)

        if let previousFrame = previousFrame, previousFrame.disposeToBackgroundColor {
            canvasContext.clear(previousFrame.drawRect(in: canvasContext))
        }

        if !blendWithPreviousFrame {
            canvasContext.clear(drawRect)
        }

        let config = try decoder.decode(at: num - 1)

        guard let provider = CGDataProvider(
            dataInfo: nil,
            data: config.output.u.RGBA.rgba,
            size: config.output.u.RGBA.size,
            releaseData: { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> Void in
                free(UnsafeMutableRawPointer(mutating: data))
        }) else {
            return
        }

        let bitmapInfo: CGBitmapInfo = config.input.has_alpha == 1
            ? [CGBitmapInfo.byteOrder32Big, CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)]
            : [CGBitmapInfo.byteOrder32Big, CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)]

        guard let image = CGImage(
            width: Int(config.output.width),
            height: Int(config.output.height),
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: Int(config.output.u.RGBA.stride),
            space: colorspace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
            ) else {
                return
        }

        canvasContext.draw(image, in: drawRect)
    }
}
