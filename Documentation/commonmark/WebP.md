# WebP

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

A view that displays an environment-dependent static or an animated webp image.

``` swift
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *) public struct WebP<Placeholder: View>: View
```

</dd>
</dl>

## Inheritance

`View`

## Methods

## resizable(capInsets:resizingMode:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the resizing mode with insets.

``` swift
public func resizable(capInsets: EdgeInsets = EdgeInsets(), resizingMode: Image.ResizingMode = .stretch) -> Self
```

### Parameters

  - capInsets: the insets.
  - resizingMode: the resizing mode.

### Returns

the view configured with the provided information.

</dd>
</dl>

## renderingMode(\_:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the rendering mode.

``` swift
public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> Self
```

### Parameters

  - renderingMode: the rendering mode.

### Returns

the view configured with the provided information.

</dd>
</dl>

## interpolation(\_:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the interpolation quality.

``` swift
public func interpolation(_ interpolation: Image.Interpolation) -> Self
```

### Parameters

  - interpolation: the interpolation quality.

### Returns

the view configured with the provided information.

</dd>
</dl>

## antialiased(\_:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the antialiasing flag.

``` swift
public func antialiased(_ isAntialiased: Bool) -> Self
```

### Parameters

  - isAntialiased: the flag.

### Returns

the view configured with the provided information.

</dd>
</dl>

## completionBehavior(\_:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the animation completion behavior.

``` swift
@discardableResult public func completionBehavior(_ completionBehavior: CompletionBehavior) -> Self
```

### Parameters

  - completionBehavior: the completion behavior.

### Returns

the view configured with the provided information.

</dd>
</dl>

## useCache(\_:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the flag to determine if the frames generated should be cached.

``` swift
@discardableResult public func useCache(_ useCache: Bool = true) -> Self
```

### Parameters

  - useCache: the flag.

### Returns

the view configured with the provided information.

</dd>
</dl>

## playBackSpeedRate(\_:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the speed factor at which the animation should be played (limited by the display refresh rate).

``` swift
@discardableResult public func playBackSpeedRate(_ playBackSpeedRate: Double) -> Self
```

> Important: Non-negative.

### Parameters

  - playBackSpeedRate: the desired speed.

### Returns

the view configured with the provided information.

</dd>
</dl>

## loopMode(\_:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the amount of time the animation should play, overriding the amount set in the image.

``` swift
@discardableResult public func loopMode(_ loopMode: WebPImage.LoopMode?) -> Self
```

### Parameters

  - loopMode: the desired loop mode.

### Returns

the view configured with the provided information.

</dd>
</dl>

## onRender(\_:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the flag to determine if the frames generated should be cached.

``` swift
@discardableResult public func onRender(_ useCache: Bool = true) -> Self
```

### Parameters

  - useCache: the flag.

### Returns

the view configured with the provided information.

</dd>
</dl>

## onPlay(\_:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the play callback.

``` swift
@discardableResult public func onPlay(_ onPlay: (() -> Void)?) -> Self
```

### Parameters

  - onPlay: the callback.

### Returns

the view configured with the provided information.

</dd>
</dl>

## onPause(\_:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the pause callback.

``` swift
@discardableResult public func onPause(_ onPause: (() -> Void)?) -> Self
```

### Parameters

  - onPause: the callback.

### Returns

the view configured with the provided information.

</dd>
</dl>

## onStop(\_:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the stop callback.

``` swift
@discardableResult public func onStop(_ onStop: (() -> Void)?) -> Self
```

### Parameters

  - onStop: the callback.

### Returns

the view configured with the provided information.

</dd>
</dl>

## onRender(\_:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the render callback.

``` swift
@discardableResult public func onRender(_ onRender: ((Int, Bool) -> Void)?) -> Self
```

### Parameters

  - onRender: the callback.

### Returns

the view configured with the provided information.

</dd>
</dl>

## onComplete(\_:)

<dl>
<dt><code>canImport(SwiftUI)</code></dt>
<dd>

Sets the completion callback.

``` swift
@discardableResult public func onComplete(_ onComplete: ((WebPImage.LoopMode) -> Void)?) -> Self
```

### Parameters

  - onComplete: the callback.

### Returns

the view configured with the provided information.

</dd>
</dl>
