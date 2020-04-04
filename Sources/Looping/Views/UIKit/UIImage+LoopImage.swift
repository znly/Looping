import UIKit

extension UIImage {

    /// Returns a UIImage from the given image at a specific frame.
    /// - Parameters:
    ///   - loopImage: The image from which to generate the frame.
    ///   - frameIndex: The frame at which the image should be generated.
    public convenience init?(loopImage: LoopImage, atFrame frameIndex: Int = 0) {
        guard let cgImage = loopImage.cgImage(atFrame: frameIndex) else {
            return nil
        }

        self.init(cgImage: cgImage, scale: loopImage.scale, orientation: .up)
    }
}
