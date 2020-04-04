import Foundation

/// Immutable representation of a frame from a loop image.
public struct Frame {

    /// Index of the frame (starts at 0).
    public let index: Int

    /// Horizontal offset within the canvas.
    public let offsetX: Int

    /// Vertical offset within the canvas.
    public let offsetY: Int

    /// Duration of the frame.
    public let duration: TimeInterval

    /// Drawing width of the frame.
    public let width: Int

    /// Drawing height of the frame.
    public let height: Int

    /// Flag to determine if the frame contains an alpha component.
    public let hasAlpha: Bool

    /// Flag to determine if we should dispose of the background before drawing.
    public let disposeToBackgroundColor: Bool

    /// Flag to determine if the frame blends into the previous one.
    public let blendWithPreviousFrame: Bool

    /// Returns an image initialized with the specified image data.
    /// - Parameters:
    ///   - index: Index of the frame (starts at 0).
    ///   - offsetX: Horizontal offset within the canvas.
    ///   - offsetY: Vertical offset within the canvas.
    ///   - duration: Duration of the frame.
    ///   - width: Drawing width of the frame.
    ///   - height: Drawing height of the frame.
    ///   - hasAlpha: Flag to determine if the frame contains an alpha component.
    ///   - disposeToBackgroundColor: Flag to determine if we should dispose of the background before drawing.
    ///   - blendWithPreviousFrame: Flag to determine if the frame blends into the previous one.
    public init(
        index: Int,
        offsetX: Int,
        offsetY: Int,
        duration: TimeInterval,
        width: Int,
        height: Int,
        hasAlpha: Bool,
        disposeToBackgroundColor: Bool,
        blendWithPreviousFrame: Bool
    ) {
        self.index = index
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.duration = duration
        self.width = width
        self.height = height
        self.hasAlpha = hasAlpha
        self.disposeToBackgroundColor = disposeToBackgroundColor
        self.blendWithPreviousFrame = blendWithPreviousFrame
    }

    var cacheKey: String {
        return String(index)
    }
}
