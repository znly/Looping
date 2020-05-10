# ChronoImage.LoopMode

Representation of the amount of time an image animation loops.

``` swift
public enum LoopMode
```

## Enumeration Cases

## infinite

Loops an infinite amount of time.

``` swift
case infinite
```

## once

Loops only once.

``` swift
case once
```

## \`repeat\`

Loops a specific amount of time.

``` swift
case `repeat`(amount: Int)
```

## Initializers

## init(amount:)

Translates a numeric value to a LoopMode.

``` swift
public init(amount: Int)
```

### Parameters

  - amount: The amount of loops.

## init(data:scale:)

Returns an image initialized with the specified webp data.

``` swift
public init(data: Data, scale: CGFloat = defaultScale) throws
```

### Parameters

  - data: The data of from a webp image.
  - scale: The scale factor of the image.

### Throws

WebPDecodingError

## init(url:)

Returns an image initialized with the specified webp url.

``` swift
public init(url: URL) throws
```

### Parameters

  - url: The url of from a webp image.

### Throws

WebPDecodingError

## init(named:bundle:)

Returns an image initialized with the specified webp image name and bundle.

``` swift
public init(named name: String, bundle: Bundle = Bundle.main) throws
```

### Parameters

  - named: The name of the webp image asset.
  - bundle: The bundle in which the image is contained.

### Throws

WebPDecodingError

## Properties

## amount

Translates the amount to a numeric value.

``` swift
var amount: Int
```

## isAnimation

A flag used to determine if the image is an animation.

``` swift
var isAnimation: Bool
```

## frameCount

The number of frames contained in the image.

``` swift
var frameCount: Int
```

## duration

The cumulative duration of all the frames.

``` swift
var duration: TimeInterval
```

## frameDurations

The individual duration of each frame.

``` swift
var frameDurations: [TimeInterval]
```

## scale

The scale factor of the image.

``` swift
let scale: CGFloat
```

## size

The size of the image.

``` swift
let size: CGSize
```

## canvasSize

The size of the canvas on which the image is rendered.

``` swift
let canvasSize: CGSize
```

## loopMode

The number of times the image should animate before stopping.

``` swift
let loopMode: LoopMode
```

## hasAlpha

A flag used to determine if the image uses alpha.

``` swift
var hasAlpha: Bool
```

## Methods

## cgImage(atFrame:)

Creates and returns a CGImage from the image at a specific frame.

``` swift
public func cgImage(atFrame frameIndex: Int = 0) -> CGImage?
```

### Parameters

  - frameIndex: The frame at which the image should be generated.

### Returns

A CGImage object that contains a snapshot of the image at the given frame or NULL if the image is not created.
