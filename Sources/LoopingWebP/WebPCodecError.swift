import Foundation

public enum WebPCodecError: Error {
    case incompleteFrame
    case codecVersionMismatch
    case featuresRetrievalFailed(String)
    case decodingFailed(String)
}
