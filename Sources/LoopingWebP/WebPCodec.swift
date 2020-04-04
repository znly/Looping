import Foundation

import class ImageIO.CGImage
import class ImageIO.CGColorSpace
import class ImageIO.CGDataProvider
import struct ImageIO.CGBitmapInfo
import enum ImageIO.CGImageAlphaInfo
import func ImageIO.CGColorSpaceCreateDeviceRGB

import Looping
import WebP

final class WebPCodec: Codec {

    private enum DataHeader {
        static let length = 12
        static let prefix = "RIFF"
        static let suffix = "WEBP"
    }

    private let data: Data
    private let demuxer: OpaquePointer?

    let isAnimation: Bool
    let hasAlpha: Bool
    let canvasWidth: Int
    let canvasHeight: Int
    let loopCount: Int
    let frameCount: Int
    let framesDuration: [TimeInterval]
    let animationDuration: TimeInterval
    let colorspace: CGColorSpace
    let areFramesIndependent = false

    static func canDecode(data: Data) -> Bool {
        guard data.count >= DataHeader.length,
            data[0] == 0x52,
            let header = String(bytes: data[0..<12], encoding: .ascii),
            header.hasPrefix(DataHeader.prefix),
            header.hasSuffix(DataHeader.suffix) else {
                return false
        }

        return true
    }

    init(data: Data) throws {
        self.data = data
        self.demuxer = try Self.generateDemuxer(data: data)

        let flags = Self.getConfigurationFlags(demuxer: demuxer)

        isAnimation = try Self.getIsAnimation(flags: flags)
        hasAlpha = Self.getAlphaConfiguration(flags: flags)
        loopCount =  Self.getLoopCount(demuxer: demuxer)
        frameCount = try Self.getFrameCount(demuxer: demuxer)
        (canvasWidth, canvasHeight) = try Self.getCanvasSize(demuxer: demuxer)
        colorspace = Self.getColorspace(demuxer: demuxer, flags: flags)
        framesDuration = Self.getframesDuration(demuxer: demuxer)
        animationDuration = framesDuration.reduce(0, +)
    }

    deinit {
        WebPDemuxDelete(demuxer)
    }

    func frame(at index: Int) throws -> Frame {
        let index = index % frameCount + 1

        guard index > 0 else {
            throw CodecError.frameIndexOutOfBounds(index)
        }

        var iterator = WebPIterator()
        defer {
            WebPDemuxReleaseIterator(&iterator)
        }

        guard WebPDemuxGetFrame(demuxer, CInt(index), &iterator) != .zero else {
            throw CodecError.frameIndexOutOfBounds(index)
        }

        guard iterator.complete == 1 else {
            throw WebPCodecError.incompleteFrame
        }

        var config = WebPDecoderConfig()
        WebPInitDecoderConfig(&config)

        return Frame(
            index: Int(iterator.frame_num) - 1,
            offsetX: Int(iterator.x_offset),
            offsetY: Int(iterator.y_offset),
            duration: Double(iterator.duration) / 1000,
            width: Int(iterator.width),
            height: Int(iterator.height),
            hasAlpha: iterator.has_alpha != 0,
            disposeToBackgroundColor: iterator.dispose_method == WEBP_MUX_DISPOSE_BACKGROUND,
            blendWithPreviousFrame: iterator.blend_method == WEBP_MUX_BLEND
        )
    }

    func decode(at index: Int) throws -> CGImage? {
        let index = index % frameCount + 1

        guard index > 0 else {
            throw CodecError.frameIndexOutOfBounds(index)
        }

        var iterator = WebPIterator()
        defer {
            WebPDemuxReleaseIterator(&iterator)
        }

        guard WebPDemuxGetFrame(demuxer, CInt(index), &iterator) != .zero else {
            throw CodecError.frameIndexOutOfBounds(index)
        }

        var config = WebPDecoderConfig()

        guard WebPInitDecoderConfig(&config) != .zero else {
            throw WebPCodecError.codecVersionMismatch
        }

        let data = iterator.fragment.bytes
        let dataSize = iterator.fragment.size

        let featuresCode = WebPGetFeatures(data, dataSize, &config.input)
        guard featuresCode == VP8_STATUS_OK else {
            throw WebPCodecError.featuresRetrievalFailed(errorString(for: featuresCode))
        }

        config.options.no_fancy_upsampling = 1
        config.options.use_threads = 1
        config.output.colorspace = MODE_rgbA

        let decodeCode = WebPDecode(data, dataSize, &config)
        guard [VP8_STATUS_OK, VP8_STATUS_NOT_ENOUGH_DATA].contains(decodeCode) else {
            throw WebPCodecError.decodingFailed(errorString(for: decodeCode))
        }

        guard let provider = CGDataProvider(
            dataInfo: nil,
            data: config.output.u.RGBA.rgba,
            size: config.output.u.RGBA.size,
            releaseData: { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> Void in
                free(UnsafeMutableRawPointer(mutating: data))
        }) else {
            throw CodecError.invalidData
        }

        let bitmapInfo: CGBitmapInfo = config.input.has_alpha == 1
            ? [CGBitmapInfo.byteOrder32Big, CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)]
            : [CGBitmapInfo.byteOrder32Big, CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)]

        return CGImage(
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
        )
    }
}

private extension WebPCodec {

    func errorString(for statusCode: VP8StatusCode) -> String {
        return "Error VP8StatusCode=\(statusCode.rawValue)"
    }

    static func getConfigurationFlags(demuxer: OpaquePointer?) -> UInt32 {
        return UInt32(WebPDemuxGetI(demuxer, WEBP_FF_FORMAT_FLAGS))
    }

    static func generateDemuxer(data: Data) throws -> OpaquePointer? {
        let webPDataP = try data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) throws -> UnsafePointer<UInt8>? in
            return bytes.baseAddress?.assumingMemoryBound(to: UInt8.self)
        }

        var webPData = WebPData(bytes: webPDataP, size: data.count)

        // Save the data in the heap and create the WebPDemuxer
        guard let demuxer = WebPDemux(&webPData) else {
            throw CodecError.invalidData
        }

        return demuxer
    }

    static func getIsAnimation(flags: UInt32) throws -> Bool {
        return (flags & ANIMATION_FLAG.rawValue) != .zero
    }

    static func getAlphaConfiguration(flags: UInt32) -> Bool {
        return (flags & ALPHA_FLAG.rawValue) != .zero
    }

    static func getLoopCount(demuxer: OpaquePointer?) -> Int {
        return Int(WebPDemuxGetI(demuxer, WEBP_FF_LOOP_COUNT))
    }

    static func getFrameCount(demuxer: OpaquePointer?) throws -> Int {
        return Int(WebPDemuxGetI(demuxer, WEBP_FF_FRAME_COUNT))
    }

    static func getCanvasSize(demuxer: OpaquePointer?) throws -> (Int, Int) {
        let canvasWidth = Int(WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH))
        let canvasHeight = Int(WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT))

        return (canvasWidth, canvasHeight)
    }

    static func getColorspace(demuxer: OpaquePointer?, flags: UInt32) -> CGColorSpace {
        var colorspace = CGColorSpaceCreateDeviceRGB()

        if #available(iOS 10.0, macOS 10.12, *) {
            // WebP format can contain its ICC Profile.
            // When available we should use the desired colorspace, instead of default one.
            // See: https://developers.google.com/speed/webp/docs/riff_container#color_profile
            let hasICCProfile = (flags & ICCP_FLAG.rawValue) != .zero

            if hasICCProfile {
                var chunkIterator = WebPChunkIterator()

                if WebPDemuxGetChunk(demuxer, "ICCP", 1, &chunkIterator) != .zero {
                    defer { WebPDemuxReleaseChunkIterator(&chunkIterator) }

                    // Copy the ICC data (really cheap, less than 10KB)
                    if let profileData = CFDataCreate(kCFAllocatorDefault, chunkIterator.chunk.bytes, chunkIterator.chunk.size) {
                        let iccColorspace = CGColorSpace(iccData: profileData)

                        // Filter out non RGB color models
                        if iccColorspace.model == .rgb {
                            colorspace = iccColorspace
                        }
                    }
                }
            }
        }

        return colorspace
    }

    // Compute durations which requires iterating on each frames
    static func getframesDuration(demuxer: OpaquePointer?) -> [TimeInterval] {
        var framesDuration = [TimeInterval]()
        var iterator = WebPIterator()
        defer { WebPDemuxReleaseIterator(&iterator) }

        if WebPDemuxGetFrame(demuxer, 1, &iterator) != .zero {
            repeat {
                let duration = iterator.duration == .zero
                    ? Self.defaultFrameDuration
                    : TimeInterval(iterator.duration) / 1000
                framesDuration.append(duration)
            } while (WebPDemuxNextFrame(&iterator) != .zero)
        }

        return framesDuration
    }
}
