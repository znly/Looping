# WebPImageModel.WebP

An object that SwiftUI object that wraps a `WebPImageView`.

``` swift
@available(iOS 13, *) public struct WebP: UIViewRepresentable
```

## Inheritance

`UIViewRepresentable`

## Nested Type Aliases

## UIViewType

Defines `WebPImageView` as the view to be presented.

``` swift
public typealias UIViewType = WebPImageView
```

## Methods

## image(\_:bundle:)

Sets the webp image to display.

``` swift
@discardableResult public func image(_ name: String, bundle: Bundle = Bundle.main) -> Self
```

### Parameters

  - name: The name of the webp image asset.
  - bundle: The bundle in which the image is contained.

### Returns

the view configured with the provided information.

## image(\_:)

Sets the webp image to display.

``` swift
@discardableResult public func image(_ image: WebPImage?) -> Self
```

### Parameters

  - image: the webp image.

### Returns

the view configured with the provided information.

## displayScale(\_:)

Sets the scale factor of the display.

``` swift
@discardableResult public func displayScale(_ displayScale: CGFloat?) -> Self
```

> Important: Strictly positive.

### Parameters

  - displayScale: the display scale.

### Returns

the view configured with the provided information.

## contentMode(\_:)

Sets the flag used to determine how a view lays out its content when its bounds change.

``` swift
@discardableResult public func contentMode(_ contentMode: ContentMode) -> Self
```

### Parameters

  - contentMode: the content mode to use to layout the content.

### Returns

the view configured with the provided information.

## autoPlay(\_:)

Sets the flag to determine if the view should start playing images automatically.

``` swift
@discardableResult public func autoPlay(_ autoPlay: Bool) -> Self
```

### Parameters

  - autoPlay: the flag.

### Returns

the view configured with the provided information.

## generateThumbnail(\_:)

Sets the flag to determine if the view generate a thumbnail image fitted to the frame size.

``` swift
@discardableResult public func generateThumbnail(_ generateThumbnail: Bool) -> Self
```

> Important: Can be CPU intensive.

### Parameters

  - generateThumbnail: the flag.

### Returns

the view configured with the provided information.

## interpolation(\_:)

Sets the level of interpolation for rendering the thumbnail image.

``` swift
@discardableResult public func interpolation(_ interpolation: Image.Interpolation?) -> Self
```

### Parameters

  - interpolation: the desired interpolation.

### Returns

the view configured with the provided information.

## useCache(\_:)

Sets the flag to determine if the frames generated should be cached.

``` swift
@discardableResult public func useCache(_ useCache: Bool) -> Self
```

### Parameters

  - useCache: the flag.

### Returns

the view configured with the provided information.

## playbackSpeed(\_:)

Sets the speed factor at which the animation should be played (limited by the display refresh rate).

``` swift
@discardableResult public func playbackSpeed(_ playbackSpeed: Double) -> Self
```

> Important: Non-negative.

### Parameters

  - playbackSpeed: the desired speed.

### Returns

the view configured with the provided information.

## loopMode(\_:)

Sets the amount of time the animation should play, overriding the amount set in the image.

``` swift
@discardableResult public func loopMode(_ loopMode: WebPImage.LoopMode?) -> Self
```

### Parameters

  - loopMode: the desired loop mode.

### Returns

the view configured with the provided information.

## completionBehavior(\_:)

Sets the behavior following the completion of the play cycle.

``` swift
@discardableResult public func completionBehavior(_ completionBehavior: CompletionBehavior) -> Self
```

### Parameters

  - completionBehavior: the desired behavior.

### Returns

the view configured with the provided information.

## aspectRatio(\_:contentMode:)

Constrains this view's dimensions to the specified aspect ratio.

``` swift
public func aspectRatio(_ aspectRatio: CGFloat? = nil, contentMode: ContentMode) -> some View
```

### Parameters

  - aspectRatio: The ratio of width to height to use for the resulting view. If `aspectRatio` is `nil`, the resulting view maintains this view's aspect ratio.
  - contentMode: A flag indicating whether this view should fit or fill the parent context.

### Returns

A view that constrains this view's dimensions to `aspectRatio`, using `contentMode` as its scaling algorithm.

## aspectRatio(\_:contentMode:)

Constrains this view's dimensions to the aspect ratio of the given size.

``` swift
public func aspectRatio(_ ratio: CGSize, contentMode: ContentMode) -> some View
```

### Parameters

  - aspectRatio: A size specifying the ratio of width to height to use for the resulting view.
  - contentMode: A flag indicating whether this view should fit or fill the parent context.

### Returns

A view that constrains this view's dimensions to `aspectRatio`, using `contentMode` as its scaling algorithm.

## scaledToFit()

Scales this view to fit its parent.

``` swift
public func scaledToFit() -> some View
```

### Returns

A view that scales this view to fit its parent, maintaining this view's aspect ratio.

## scaledToFill()

Scales this view to fill its parent.

``` swift
public func scaledToFill() -> some View
```

### Returns

A view that scales this view to fit its parent, maintaining this view's aspect ratio.
