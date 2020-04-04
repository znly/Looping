import Foundation

public struct Frame {
    public let index: Int
    public let offsetX: Int
    public let offsetY: Int
    public let duration: TimeInterval
    public let width: Int
    public let height: Int
    public let hasAlpha: Bool
    public let disposeToBackgroundColor: Bool
    public let blendWithPreviousFrame: Bool

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
