import Foundation

public enum DecodingError: Error {
    case invalidAsset
    case invalidData
    case invalidFileFormat
    case invalidScale
    case noFramesFound
    case invalidCanvas
    case invalidFrameIndex(Int)
    case incompleteFrame
    case configurationFailed
    case featuresRetrievalFailed(String)
    case decodeFailed(String)
}
