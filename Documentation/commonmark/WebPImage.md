# WebPImage

Immutable representation of a webp image.

``` swift
public struct WebPImage
```

You can use image objects in several different ways:

## Inheritance

`CustomDebugStringConvertible`

## Properties

## debugDescription

A textual representation of this instance, suitable for debugging.

``` swift
var debugDescription: String
```

## debugDescription

A textual representation of this instance, suitable for debugging.

``` swift
var debugDescription: String
```

## description

A textual representation of this instance.

``` swift
var description: String
```

## defaultScale

Default scale value for an image.

``` swift
let defaultScale: CGFloat = 1
```

## Methods

## image(atFrame:)

Creates and returns a UIImage from the image at a specific frame.

``` swift
public func image(atFrame frameIndex: Int = 0) -> UIImage?
```

### Parameters

  - frameIndex: The frame at which the image should be generated.

### Returns

A UIImage object that contains a snapshot of the image at the given frame or NULL if the image is not created.
