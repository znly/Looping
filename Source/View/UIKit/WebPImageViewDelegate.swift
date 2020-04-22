import Foundation

/// Respond to messages from the WebPImageView class to operations related to image animations.
public protocol WebPImageViewDelegate: class {

    /// Called by the image view when the image animation started playing.
    /// - Parameters:
    ///   - imageView: The image view animating the image.
    ///   - image: The image being animated.
    func imageView(_ imageView: WebPImageView, didStartPlayingImage image: WebPImage)

    /// Called by the image view when the image animation paused playing.
    /// - Parameters:
    ///   - imageView: The image view animating the image.
    ///   - image: The image being animated.
    func imageView(_ imageView: WebPImageView, didPausePlayingImage image: WebPImage)

    /// Called by the image view when the image animation stopped playing.
    /// - Parameters:
    ///   - imageView: The image view animating the image.
    ///   - image: The image being animated.
    func imageView(_ imageView: WebPImageView, didStopPlayingImage image: WebPImage)

    /// Called by the image view when the image animation finished playing.
    /// - Parameters:
    ///   - imageView: The image view animating the image.
    ///   - image: The image being animated.
    ///   - loopCount: The number of times the animation looped.
    func imageView(_ imageView: WebPImageView, didFinishPlayingImage image: WebPImage, loopMode: WebPImage.LoopMode)
}
