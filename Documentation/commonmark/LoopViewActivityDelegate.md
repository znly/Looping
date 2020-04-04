# LoopViewActivityDelegate

Respond to messages from the LoopView class to operations related to display and render.

``` swift
public protocol LoopViewActivityDelegate: class
```

## Inheritance

`class`

## Requirements

## loopView(\_:didRenderFrameAtIndex:fromCache:)

Called by the loop view when it renders a frame.

``` swift
func loopView(_ loopView: LoopView, didRenderFrameAtIndex index: Int, fromCache didUseCache: Bool)
```

### Parameters

  - loopView: The loop view rendering the image.
  - index: The index of the frame.
  - fromCache: A flag indicating if the frame was rendered from cache.

## loopView(\_:didDisplay:)

Called by the loop view when it displays a frame.

``` swift
func loopView(_ loopView: LoopView, didDisplay image: CGImage?)
```

### Parameters

  - loopView: The loop view displaying the image.
  - image: The (thumbnail) image of the canvas.
