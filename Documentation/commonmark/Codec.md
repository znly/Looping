# Codec

``` swift
public protocol Codec
```

## Requirements

## isAnimation

``` swift
var isAnimation: Bool
```

## hasAlpha

``` swift
var hasAlpha: Bool
```

## canvasWidth

``` swift
var canvasWidth: Int
```

## canvasHeight

``` swift
var canvasHeight: Int
```

## loopCount

``` swift
var loopCount: Int
```

## frameCount

``` swift
var frameCount: Int
```

## framesDuration

``` swift
var framesDuration: [TimeInterval]
```

## animationDuration

``` swift
var animationDuration: TimeInterval
```

## colorspace

``` swift
var colorspace: CGColorSpace
```

## areFramesIndependent

``` swift
var areFramesIndependent: Bool
```

## register()

``` swift
static func register()
```

## canDecode(data:)

``` swift
static func canDecode(data: Data) -> Bool
```

## frame(at:)

``` swift
func frame(at index: Int) throws -> Frame
```

## decode(at:)

``` swift
func decode(at index: Int) throws -> CGImage?
```

## register()

``` swift
public static func register()
```

## defaultFrameDuration

``` swift
var defaultFrameDuration: TimeInterval
```
