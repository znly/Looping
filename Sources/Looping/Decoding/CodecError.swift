import Foundation

public enum CodecError: Error {
    case invalidData
    case frameIndexOutOfBounds(Int)
}
