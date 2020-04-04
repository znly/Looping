import Foundation

/// Errors thrown when decoding a loop image.
public enum CodecError: Error {

    /// Failed to decode the provided data.
    case invalidData

    /// Accessing a frame that does not exists.
    case frameIndexOutOfBounds(Int)
}
