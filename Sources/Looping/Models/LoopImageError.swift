import Foundation

/// Errors thrown when loading a loop image.
public enum LoopImageError: Error {

    /// Codec cannot be found.
    case noMatchingCodec

    /// Asset cannot be found.
    case missingAsset
}
