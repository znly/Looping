# WebPImageViewDelegate

Respond to messages from the WebPImageView class to operations related to image animations.

``` swift
public protocol WebPImageViewDelegate: class
```

## Inheritance

`class`

## Requirements

## imageView(\_:didStartPlayingImage:)

Called by the image view when the image animation started playing.

``` swift
func imageView(_ imageView: WebPImageView, didStartPlayingImage image: WebPImage)
```

### Parameters

  - imageView: The image view animating the image.
  - image: The image being animated.

## imageView(\_:didPausePlayingImage:)

Called by the image view when the image animation paused playing.

``` swift
func imageView(_ imageView: WebPImageView, didPausePlayingImage image: WebPImage)
```

### Parameters

  - imageView: The image view animating the image.
  - image: The image being animated.

## imageView(\_:didStopPlayingImage:)

Called by the image view when the image animation stopped playing.

``` swift
func imageView(_ imageView: WebPImageView, didStopPlayingImage image: WebPImage)
```

### Parameters

  - imageView: The image view animating the image.
  - image: The image being animated.

## imageView(\_:didFinishPlayingImage:loopMode:)

Called by the image view when the image animation finished playing.

``` swift
func imageView(_ imageView: WebPImageView, didFinishPlayingImage image: WebPImage, loopMode: WebPImage.LoopMode)
```

### Parameters

  - imageView: The image view animating the image.
  - image: The image being animated.
  - loopCount: The number of times the animation looped.
