# WebPImageView.CompletionBehavior

A list of behavior following the completion of the play cycle.

``` swift
public enum CompletionBehavior
```

## Enumeration Cases

## stop

Stops the rendering once completion is reached.

``` swift
case stop
```

## pause

Pauses the rendering once completion is reached.

``` swift
case pause
```

## Initializers

## init(image:)

Returns an image view initialized with the specified image.

``` swift
public convenience init(image: WebPImage?)
```

### Parameters

  - image: The initial image to display in the image view.

## init(frame:)

Initializes and returns a newly allocated view object with the specified frame rectangle.

``` swift
public override init(frame: CGRect)
```

### Parameters

  - frame: The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.

## init?(coder:)

Initializes and returns a newly allocated view object with the specified coder.

``` swift
public required init?(coder: NSCoder)
```

### Parameters

  - coder: The coder for the view.

## Properties

## image

The webp image being displayed.

``` swift
var image: WebPImage?
```

## displayScale

The scale factor of the display.

``` swift
var displayScale: CGFloat = UIScreen.main.scale
```

> Important: Strictly positive.

## contentMode

A flag used to determine how a view lays out its content when its bounds change.

``` swift
var contentMode: ContentMode
```

## autoPlay

A flag to determine if the view should start playing images automatically.

``` swift
var autoPlay = true
```

## generateThumbnail

A flag to determine if the view generate a thumbnail image fitted to the frame size.

``` swift
var generateThumbnail = false
```

> Important: Can be CPU intensive.

## interpolationQuality

Levels of interpolation quality for rendering the thumbnail image.

``` swift
var interpolationQuality: CGInterpolationQuality
```

## useCache

A flag to determine if the frames generated should be cached.

``` swift
var useCache: Bool
```

## playbackSpeed

The speed factor at which the animation should be played (limited by the display refresh rate).

``` swift
var playbackSpeed: Double
```

> Important: Non-negative.

## loopMode

The amount of time the animation should play, overriding the amount set in the image.

``` swift
var loopMode: WebPImage.LoopMode?
```

## completionBehavior

The behavior following the completion of the play cycle.

``` swift
var completionBehavior: CompletionBehavior = .pause
```

## isPlaying

Returns true if the image animation is playing.

``` swift
var isPlaying: Bool
```

## layerClass

Returns the class used to create the layer for instances of this class.

``` swift
var layerClass: AnyClass
```

## intrinsicContentSize

The natural size for the receiving view, considering only properties of the view itself.

``` swift
var intrinsicContentSize: CGSize
```

## Methods

## play(loopMode:useCache:completion:)

Plays the animation of the image.

``` swift
open func play(loopMode: WebPImage.LoopMode? = nil, useCache: Bool? = nil, completion: CompletionCallback? = nil)
```

### Parameters

  - loopMode: The amount of time the animation should play or left to nil to keep current behavior.
  - useCache: A flag to determine if the frames generated should be cached or left to nil to keep current behavior.
  - completion: The callback handler called at the completion play cycle.

## playOnce(completion:)

Plays the animation of the image.

``` swift
open func playOnce(completion: CompletionCallback? = nil)
```

### Parameters

  - completion: The callback handler called at the completion play cycle.

## playRepeat(amount:completion:)

Plays the animation of the image.

``` swift
open func playRepeat(amount: Int, completion: CompletionCallback? = nil)
```

### Parameters

  - amount: The amount of animation repetitions.
  - image: The callback handler called at the completion play cycle.

## playIndefinitely(completion:)

Plays the animation of the image.

``` swift
open func playIndefinitely(completion: CompletionCallback? = nil)
```

### Parameters

  - image: The callback handler called at the completion play cycle.

## pause()

Pauses the animation of the image.

``` swift
open func pause()
```

## stop()

Stops the animation of the image.

``` swift
open func stop()
```

## layoutSubviews()

Lays out subviews.

``` swift
override open func layoutSubviews()
```

## didMoveToWindow()

Tells the view that its window object changed.

``` swift
override open func didMoveToWindow()
```

## didMoveToSuperview()

Tells the view that its superview changed.

``` swift
override open func didMoveToSuperview()
```
