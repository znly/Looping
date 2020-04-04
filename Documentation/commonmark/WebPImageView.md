# WebPImageView

An object that displays a static or an animated webp image in your interface.

``` swift
@IBDesignable open class WebPImageView: UIView
```

## Inheritance

`UIView`

## Nested Type Aliases

## CompletionCallback

A callback handler called at the completion play cycle.

``` swift
public typealias CompletionCallback = (Bool) -> Void
```

## Properties

## delegate

The delegate of the image view object.

``` swift
var delegate: WebPImageViewDelegate?
```

## activityDelegate

The activity delegate of the image view object.

``` swift
var activityDelegate: WebPImageViewActivityDelegate?
```
