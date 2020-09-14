import Foundation

import class UIKit.UIImage

/// Respond to messages from the LoopView class to operations related to display and render.
public protocol LoopViewActivityDelegate: class {

    /// Called by the loop view when it renders a frame.
    /// - Parameters:
    ///   - loopView: The loop view rendering the image.
    ///   - index: The index of the frame.
    ///   - fromCache: A flag indicating if the frame was rendered from cache.
    func loopView(_ loopView: LoopView, didRenderFrameAtIndex index: Int, fromCache didUseCache: Bool)

    /// Called by the loop view when it displays a frame.
    /// - Parameters:
    ///   - loopView: The loop view displaying the image.
    ///   - image: The (thumbnail) image of the canvas.
    ///   - index: The index of the frame.
    func loopView(_ loopView: LoopView, didDisplayImage image: UIImage?, forFrameAtIndex index: Int?)
}
