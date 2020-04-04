import Foundation

enum WebPImageError: Error {
    case invalidData
    case invalidScale
    case noFramesFound
    case invalidCanvas
    case invalidFrameIndex(Int)
    case incompleteFrame
    case configurationFailed
    case featuresRetrievalFailed(String)
    case decodeFailed(String)
}
