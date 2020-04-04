import Foundation

/// Respond to messages from the LoopView class to operations related to image animations.
public protocol LoopViewDelegate: class {

    /// Called by the loop view when the image animation started playing.
    /// - Parameters:
    ///   - loopView: The loop view animating the image.
    ///   - image: The image being played.
    func loopView(_ loopView: LoopView, didStartPlayingImage image: LoopImage)

    /// Called by the loop view when the image animation paused playing.
    /// - Parameters:
    ///   - loopView: The loop view animating the image.
    ///   - image: The image being played.
    func loopView(_ loopView: LoopView, didPausePlayingImage image: LoopImage)

    /// Called by the loop view when the image animation stopped playing.
    /// - Parameters:
    ///   - loopView: The loop view animating the image.
    ///   - image: The image being played.
    func loopView(_ loopView: LoopView, didStopPlayingImage image: LoopImage)

    /// Called by the image loop when the image animation finished playing.
    /// - Parameters:
    ///   - loopView: The loop view animating the image.
    ///   - image: The image being animated.
    ///   - loopCount: The number of times the image was played.
    func loopView(_ loopView: LoopView, didFinishPlayingImage image: LoopImage, loopMode: LoopImage.LoopMode)
}
