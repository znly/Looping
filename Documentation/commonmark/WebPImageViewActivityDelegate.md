# WebPImageViewActivityDelegate

Respond to messages from the WebPImageView class to operations related to display and render.

``` swift
public protocol WebPImageViewActivityDelegate: class
```

## Inheritance

`class`

## Requirements

## imageView(\_:didRenderFrameAtIndex:)

Called by the image view when it renders a frame.

``` swift
func imageView(_ imageView: WebPImageView, didRenderFrameAtIndex index: Int)
```

### Parameters

  - imageView: The image view rendering the image.
  - index: The index of the frame.

## imageView(\_:didDisplay:)

Called by the image view when it displays a frame.

``` swift
func imageView(_ imageView: WebPImageView, didDisplay image: CGImage?)
```

### Parameters

  - imageView: The image view displaying the image.
  - image: The (thumbnail) image of the canvas.
