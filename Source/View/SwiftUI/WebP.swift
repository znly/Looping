#if canImport(SwiftUI)
import SwiftUI

/// A view that displays an environment-dependent static or an animated webp image.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct WebP<Placeholder: View>: View {

    /// A list of behavior following the completion of the play cycle.
    @frozen public enum CompletionBehavior {

        /// Stops the rendering once completion is reached.
        case stop

        /// Pauses the rendering once completion is reached.
        case pause
    }

    fileprivate final class Renderer: ObservableObject {

        private var image: WebPImage
        fileprivate var renderer: WebPImageRenderer!

        @Published var renderedImage: CGImage?

        var onPlay: (() -> Void)?
        var onPause: (() -> Void)?
        var onStop: (() -> Void)?
        var onRender: ((Int, Bool) -> Void)?
        var onComplete: ((WebPImage.LoopMode) -> Void)?
        var completionBehavior: CompletionBehavior = .stop

        /// Returns an webp view initialized with the specified image.
        /// - Parameter image: The image to display in the view.
        init(image: WebPImage) {
            self.image = image
            renderer = WebPImageRenderer(image: image, useCache: true, playBackSpeedRate: 1.0, viewLoopMode: nil) { [weak self] image in
                DispatchQueue.main.async {
                    self?.renderedImage = image
                }
            }
            renderer.delegateCallback = { [weak self] event in
                self?.forward(event)
            }
        }

        private func forward(_ event: WebPImageRenderer.DelegateEvent) {
            switch event {
            case .didStartPlaying:
                onPlay?()
            case .didPausePlaying:
                onPause?()
            case .didStopPlaying:
                onStop?()
            case let .didCompletePlaying(loopMode):
                onComplete?(loopMode)
                if image.isAnimation && completionBehavior == .stop {
                    renderer.stop()
                } else {
                    renderer.pause()
                }
            case let .didRenderFrame(index, didUseCache):
                onRender?(index, didUseCache)
            }
        }
    }

    private final class Layout: ObservableObject {
        enum Modifier {
            case resize(EdgeInsets, Image.ResizingMode)
            case renderingMode(Image.TemplateRenderingMode?)
            case interpolation(Image.Interpolation)
            case antialiased(Bool)
        }

        var modifiers = [Modifier]()
    }

    @ObservedObject private var renderer: Renderer
    @ObservedObject private var layout = Layout()
    @Binding private var isPlaying: Bool

    private let placeholder: Placeholder

    /// Returns an webp view initialized.
    /// - Parameters:
    ///   - image: The image to display in the view.
    ///   - isPlaying: A binding to control when the webp should play.
    ///   - placeholder: A placeholder to use until the first frame of the image is played.
    public init(_ image: WebPImage,
                isPlaying: Binding<Bool> = .constant(true),
                @ViewBuilder placeholder: () -> Placeholder) {
        self.placeholder = placeholder()
        renderer = Renderer(image: image)
        self._isPlaying = isPlaying
    }

    /// Returns an webp view initialized.
    /// - Parameters:
    ///   - url: The url to fetch the image from.
    ///   - isPlaying: A binding to control when the webp should play.
    ///   - placeholder: A placeholder to use until the first frame of the image is played.
    public init(_ url: URL,
                isPlaying: Binding<Bool> = .constant(true),
                @ViewBuilder placeholder: () -> Placeholder) {
        self.init(try! WebPImage(url: url), isPlaying: isPlaying, placeholder: placeholder)
    }

    /// Returns an webp view initialized.
    /// - Parameters:
    ///   - name: The name of the image to fetch.
    ///   - bundle: The bundle to fetch the image from.
    ///   - isPlaying: A binding to control when the webp should play.
    ///   - placeholder: A placeholder to use until the first frame of the image is played.
    public init(_ name: String,
                bundle: Bundle = Bundle.main,
                isPlaying: Binding<Bool> = .constant(true),
                @ViewBuilder placeholder: () -> Placeholder) {
        self.init(try! WebPImage(named: name, bundle: bundle), isPlaying: isPlaying, placeholder: placeholder)
    }

    /// The content and behavior of the view.
    public var body: some View {
        if isPlaying {
            renderer.start()
        } else {
            renderer.pause()
        }

        let image = imageWithModifiers()

        return Group {
            if image != nil {
                image!
            } else {
                placeholder
            }
        }
    }

    private func imageWithModifiers() -> Image? {
        let renderedImage = renderer.renderedImage.map { Image(decorative: $0, scale: 1) }
        guard var image = renderedImage else {
            return nil
        }

        for modifier in layout.modifiers {
            switch modifier {
            case let .resize(capInsets, resizingMode):
                image = image.resizable(capInsets: capInsets, resizingMode: resizingMode)
            case let .interpolation(interpolation):
                image = image.interpolation(interpolation)
            case let .renderingMode(renderingMode):
                image = image.renderingMode(renderingMode)
            case let .antialiased(isAntialiased):
                image = image.antialiased(isAntialiased)
            }
        }

        return image
    }
}

/// MARK: Layout options
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension WebP {

    /// Sets the resizing mode with insets.
    /// - Parameter capInsets: the insets.
    /// - Parameter resizingMode: the resizing mode.
    /// - Returns: the view configured with the provided information.
    public func resizable(capInsets: EdgeInsets = EdgeInsets(), resizingMode: Image.ResizingMode = .stretch) -> Self {
        layout.modifiers.append(.resize(capInsets, resizingMode))
        return self
    }

    /// Sets the rendering mode.
    /// - Parameter renderingMode: the rendering mode.
    /// - Returns: the view configured with the provided information.
    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> Self {
        layout.modifiers.append(.renderingMode(renderingMode))
        return self
    }

    /// Sets the interpolation quality.
    /// - Parameter interpolation: the interpolation quality.
    /// - Returns: the view configured with the provided information.
    public func interpolation(_ interpolation: Image.Interpolation) -> Self {
        layout.modifiers.append(.interpolation(interpolation))
        return self
    }

    /// Sets the antialiasing flag.
    /// - Parameter isAntialiased: the flag.
    /// - Returns: the view configured with the provided information.
    public func antialiased(_ isAntialiased: Bool) -> Self {
        layout.modifiers.append(.antialiased(isAntialiased))
        return self
    }
}

/// MARK: Rendering options
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension WebP {

    /// Sets the animation completion behavior.
    /// - Parameter completionBehavior: the completion behavior.
    /// - Returns: the view configured with the provided information.
    @discardableResult
    public func completionBehavior(_ completionBehavior: CompletionBehavior) -> Self {
        renderer.completionBehavior = completionBehavior
        return self
    }

    /// Sets the flag to determine if the frames generated should be cached.
    /// - Parameter useCache: the flag.
    /// - Returns: the view configured with the provided information.
    @discardableResult
    public func useCache(_ useCache: Bool = true) -> Self {
        renderer.useCache(useCache)
        return self
    }

    /// Sets the speed factor at which the animation should be played (limited by the display refresh rate).
    /// - Important: Non-negative.
    /// - Parameter playBackSpeedRate: the desired speed.
    /// - Returns: the view configured with the provided information.
    @discardableResult
    public func playBackSpeedRate(_ playBackSpeedRate: Double) -> Self {
        renderer.playBackSpeedRate(playBackSpeedRate)
        return self
    }

    /// Sets the amount of time the animation should play, overriding the amount set in the image.
    /// - Parameter loopMode: the desired loop mode.
    /// - Returns: the view configured with the provided information.
    @discardableResult
    public func loopMode(_ loopMode: WebPImage.LoopMode?) -> Self {
        renderer.loopMode(loopMode)
        return self
    }

    /// Sets the flag to determine if the frames generated should be cached.
    /// - Parameter useCache: the flag.
    /// - Returns: the view configured with the provided information.
    @discardableResult
    public func onRender(_ useCache: Bool = true) -> Self {
        renderer.useCache(useCache)
        return self
    }

    /// Sets the play callback.
    /// - Parameter onPlay: the callback.
    /// - Returns: the view configured with the provided information.
    @discardableResult
    public func onPlay(_ onPlay: (() -> Void)?) -> Self {
        renderer.onPlay = onPlay
        return self
    }

    /// Sets the pause callback.
    /// - Parameter onPause: the callback.
    /// - Returns: the view configured with the provided information.
    @discardableResult
    public func onPause(_ onPause: (() -> Void)?) -> Self {
        renderer.onPause = onPause
        return self
    }

    /// Sets the stop callback.
    /// - Parameter onStop: the callback.
    /// - Returns: the view configured with the provided information.
    @discardableResult
    public func onStop(_ onStop: (() -> Void)?) -> Self {
        renderer.onStop = onStop
        return self
    }

    /// Sets the render callback.
    /// - Parameter onRender: the callback.
    /// - Returns: the view configured with the provided information.
    @discardableResult
    public func onRender(_ onRender: ((Int, Bool) -> Void)?) -> Self {
        renderer.onRender = onRender
        return self
    }

    /// Sets the completion callback.
    /// - Parameter onComplete: the callback.
    /// - Returns: the view configured with the provided information.
    @discardableResult
    public func onComplete(_ onComplete: ((WebPImage.LoopMode) -> Void)?) -> Self {
        renderer.onComplete = onComplete
        return self
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
private extension WebP.Renderer {

    func start() {
        renderer.start()
    }

    func pause() {
        renderer.pause()
    }

    func useCache(_ useCache: Bool) {
        renderer.useCache = useCache
    }

    func playBackSpeedRate(_ playBackSpeedRate: Double) {
        renderer.playBackSpeedRate = playBackSpeedRate
    }

    func loopMode(_ loopMode: WebPImage.LoopMode?) {
        renderer.viewLoopMode = loopMode
    }
}
#endif
