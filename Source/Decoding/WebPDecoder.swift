import Foundation

import class CoreGraphics.CGColorSpace
import func CoreGraphics.CGColorSpaceCreateDeviceRGB

import WebP

class WebPDecoder {
    private var data: Data
    private let demuxer: OpaquePointer?

    let isAnimation: Bool
    let hasAlpha: Bool
    let canvasWidth: Int
    let canvasHeight: Int
    let loopCount: Int
    let frameCount: Int
    let frameDurations: [TimeInterval]
    let animationDuration: TimeInterval
    var colorspace: CGColorSpace

    init(data: Data) throws {
        self.data = data
        self.demuxer = try WebPDecoder.generateDemuxer(data: data)

        let flags = WebPDecoder.getConfigurationFlags(demuxer: demuxer)

        isAnimation = try WebPDecoder.getIsAnimation(flags: flags)
        hasAlpha = WebPDecoder.getAlphaConfiguration(flags: flags)
        loopCount =  WebPDecoder.getLoopCount(demuxer: demuxer)
        frameCount = try WebPDecoder.getFrameCount(demuxer: demuxer)
        (canvasWidth, canvasHeight) = try WebPDecoder.getCanvasSize(demuxer: demuxer)
        colorspace = WebPDecoder.getColorspace(demuxer: demuxer, flags: flags)
        frameDurations = WebPDecoder.getFrameDurations(demuxer: demuxer)
        animationDuration = frameDurations.reduce(0, +)
    }

    deinit {
        WebPDemuxDelete(demuxer)
    }

    func frame(at index: Int) throws -> WebPImageFrame {
        let index = index % frameCount + 1

        guard index > 0 else {
            throw WebPImageError.invalidFrameIndex(index)
        }

        var iterator = WebPIterator()
        defer {
            WebPDemuxReleaseIterator(&iterator)
        }

        guard WebPDemuxGetFrame(demuxer, CInt(index), &iterator) != .zero else {
            throw WebPImageError.invalidFrameIndex(index)
        }

        guard iterator.complete == 1 else {
            throw WebPImageError.incompleteFrame
        }

        var config = WebPDecoderConfig()
        WebPInitDecoderConfig(&config)

        return WebPImageFrame(iterator: iterator, decoder: self)
    }

    private func errorString(for statusCode: VP8StatusCode) -> String {
        return "Error VP8StatusCode=\(statusCode.rawValue)"
    }

    func decode(at index: Int) throws -> WebPDecoderConfig {
        let index = index % frameCount + 1

        guard index > 0 else {
            throw WebPImageError.invalidFrameIndex(index)
        }

        var iterator = WebPIterator()
        defer {
            WebPDemuxReleaseIterator(&iterator)
        }

        guard WebPDemuxGetFrame(demuxer, CInt(index), &iterator) != .zero else {
            throw WebPImageError.invalidFrameIndex(index)
        }

        var config = WebPDecoderConfig()

        guard WebPInitDecoderConfig(&config) != .zero else {
            throw WebPImageError.configurationFailed
        }

        let data = iterator.fragment.bytes
        let dataSize = iterator.fragment.size

        let featuresCode = WebPGetFeatures(data, dataSize, &config.input)
        guard featuresCode == VP8_STATUS_OK else {
            throw WebPImageError.featuresRetrievalFailed(errorString(for: featuresCode))
        }

        config.options.no_fancy_upsampling = 1
        config.options.use_threads = 1
        config.output.colorspace = MODE_rgbA

        let decodeCode = WebPDecode(data, dataSize, &config)
        guard [VP8_STATUS_OK, VP8_STATUS_NOT_ENOUGH_DATA].contains(decodeCode) else {
            throw WebPImageError.decodeFailed(errorString(for: decodeCode))
        }

        return config
    }
}

private extension WebPDecoder {

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
            throw WebPImageError.invalidData
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
        let frameCount = Int(WebPDemuxGetI(demuxer, WEBP_FF_FRAME_COUNT))

        guard frameCount > 0 else {
            throw WebPImageError.noFramesFound
        }

        return frameCount
    }

    static func getCanvasSize(demuxer: OpaquePointer?) throws -> (Int, Int) {
        let canvasWidth = Int(WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH))
        let canvasHeight = Int(WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT))

        guard canvasWidth > 0, canvasHeight > 0 else {
            throw WebPImageError.invalidCanvas
        }

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
    static func getFrameDurations(demuxer: OpaquePointer?) -> [TimeInterval] {
        var frameDurations = [TimeInterval]()
        var iterator = WebPIterator()
        defer { WebPDemuxReleaseIterator(&iterator) }

        if WebPDemuxGetFrame(demuxer, 1, &iterator) != .zero {
            repeat {
                frameDurations.append(TimeInterval(iterator.duration) / 1000)
            } while (WebPDemuxNextFrame(&iterator) != .zero)
        }

        return frameDurations
    }
}
