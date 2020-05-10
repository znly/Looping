# LoopViewDelegate

Respond to messages from the LoopView class to operations related to image animations.

``` swift
public protocol LoopViewDelegate: class
```

## Inheritance

`class`

## Requirements

## loopView(\_:didStartPlayingImage:)

Called by the loop view when the image animation started playing.

``` swift
func loopView(_ loopView: LoopView, didStartPlayingImage image: LoopImage)
```

### Parameters

  - loopView: The loop view animating the image.
  - image: The image being animated.

## loopView(\_:didPausePlayingImage:)

Called by the loop view when the image animation paused playing.

``` swift
func loopView(_ loopView: LoopView, didPausePlayingImage image: LoopImage)
```

### Parameters

  - loopView: The loop view animating the image.
  - image: The image being animated.

## loopView(\_:didStopPlayingImage:)

Called by the loop view when the image animation stopped playing.

``` swift
func loopView(_ loopView: LoopView, didStopPlayingImage image: LoopImage)
```

### Parameters

  - loopView: The loop view animating the image.
  - image: The image being animated.

## loopView(\_:didFinishPlayingImage:loopMode:)

Called by the image loop when the image animation finished playing.

``` swift
func loopView(_ loopView: LoopView, didFinishPlayingImage image: LoopImage, loopMode: LoopImage.LoopMode)
```

### Parameters

  - loopView: The loop view animating the image.
  - image: The image being animated.
  - loopCount: The number of times the animation looped.
