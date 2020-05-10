import UIKit

extension LoopImage {

    /// Creates and returns a UIImage from the image at a specific frame.
    /// - Parameter frameIndex: The frame at which the image should be generated.
    /// - Returns: A UIImage object that contains a snapshot of the image at the given frame or NULL if the image is not created.
    public func image(atFrame frameIndex: Int = 0) -> UIImage? {
        return cgImage(atFrame: frameIndex)
            .map { UIImage(cgImage: $0, scale: scale, orientation: .up) }
    }
}
