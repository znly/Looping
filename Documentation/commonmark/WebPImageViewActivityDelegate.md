# WebPImageViewActivityDelegate

Respond to messages from the WebPImageView class to operations related to display and render.

``` swift
public protocol WebPImageViewActivityDelegate: class
```

## Inheritance

`class`

## Requirements

## imageView(\_:didRenderFrameAtIndex:fromCache:)

Called by the image view when it renders a frame.

``` swift
func imageView(_ imageView: WebPImageView, didRenderFrameAtIndex index: Int, fromCache didUseCache: Bool)
```

### Parameters

  - imageView: The image view rendering the image.
  - index: The index of the frame.
  - fromCache: A flag indicating if the frame was rendered from cache.

## imageView(\_:didDisplay:)

Called by the image view when it displays a frame.

``` swift
func imageView(_ imageView: WebPImageView, didDisplay image: CGImage?)
```

### Parameters

  - imageView: The image view displaying the image.
  - image: The (thumbnail) image of the canvas.