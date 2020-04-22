import UIKit

extension UIImage {

    /// Returns a UIImage from the given image at a specific frame.
    /// - Parameters:
    ///   - wpImage: The image from which to generate the frame.
    ///   - frameIndex: The frame at which the image should be generated.
    public convenience init?(wpImage: WebPImage, atFrame frameIndex: Int = 0) {
        guard let cgImage = wpImage.cgImage(atFrame: frameIndex) else {
            return nil
        }

        self.init(cgImage: cgImage, scale: wpImage.scale, orientation: .up)
    }
}
