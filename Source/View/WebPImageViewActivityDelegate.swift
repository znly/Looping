import Foundation

import class CoreGraphics.CGImage

/// Respond to messages from the WebPImageView class to operations related to display and render.
public protocol WebPImageViewActivityDelegate: class {

    /// Called by the image view when it renders a frame.
    /// - Parameters:
    ///   - imageView: The image view rendering the image.
    ///   - index: The index of the frame.
    func imageView(_ imageView: WebPImageView, didRenderFrameAtIndex index: Int)

    /// Called by the image view when it displays a frame.
    /// - Parameters:
    ///   - imageView: The image view displaying the image.
    ///   - image: The (thumbnail) image of the canvas.
    func imageView(_ imageView: WebPImageView, didDisplay image: CGImage?)
}
