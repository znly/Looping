# ➰Looping

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![SwiftPM Support](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Carthage Support](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)

## What is Looping?

A simple and lightweight framework to display looping images using native UIKit and SwiftUI.

### Supported formats

Out of the box, Looping supports natively 4 formats of __animated__ and __still__ images:
- **GIF**
- **APNG**
- **HEIC** starting at _iOS 13_
- **WebP** starting at _iOS 14_

However, you can easily add unrestricted WebP support by including and enabling the complementary **LoopingWebP** framework:

```swift
import Looping
import LoopingWebP

LoopImage.enableWebP()
```

### Dependencies

+ **Looping** has no external dependency.
+ **LoopingWebP** depends on [Google's libwebp](https://github.com/webmproject/libwebp/releases/tag/v1.1.0).

### Next steps

+ CocoaPod support.
+ Unit tests coverage.
+ `BackgroundBehavior` (restart, stop, resume).
+ Progressive decoding option.
+ Native support on macOS, watchOS, tvOS.

### Minimum deployment targets

+ iOS 11
+ macOS 10.15

### Project requirements

+ Xcode 11 (swift 5.1)

## Installation

### SwiftPM

[Swift Package Manager (SwiftPM)](https://swift.org/package-manager/) is dependency manager as well as a distribution tool.

From Xcode 11 onward, SwiftPM is natively integrated with Xcode. In `File -> Swift Packages -> Add Package Dependency`, search for WebPImage's repo URL.

If you're a framework author, you can add following the dependency to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/znly/Looping.git", .from("1.3.0"))
]
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

To integrate Looping into your Xcode project using Carthage, specify it in your Cartfile:
```
github "znly/Looping" ~> 1.3.0
```

## Usage

### ① Creating a `LoopImage`

The prefered method is to use `init(data:, scale:)`. Default scale is 1.0.
```swift
import Looping

let imageData: Data
let image = try? LoopImage(data: imageData)
```

Additional convenience initializers are available: `init(url:)` and  `init(named:)`.
Note: If the file name contains a scale factor (eg: @{1,2,3}x) it will be applied to the image.

### ② Displaying a `LoopImage`

Rendering happens on a background thread. 

#### Using `LoopView` (UIKit)

```swift
import Looping

let image: LoopImage
let imageView = LoopView(loopImage: image)

loopView.contentMode = .scaleAspectFit
loopView.loopMode = .once
```

#### Using `Loop` (SwiftUI)

```swift
import Looping

let image: LoopImage

struct ContentView: View {
    var body: some View {
        Loop(image)
            .loopMode(.once)
            .resizable()
            .scaledToFit()
    }
}
```

### ③ Converting a `LoopImage` frame into a `UIImage` or `CGImage`

Using either the methods for a single frame `LoopImage.cgImage(atFrame:)` and  `LoopImage.image(atFrame:)`, or for a range of frames `LoopImage.cgImages(atRange:)`.

 For WebP images, since retrieving the image of at a specific frame requires to go over every intermediary frame to reconstruct the final image, it is recommended to call these methods outside of the main thread. 

```swift
import Looping

let loopImage: LoopImage
let cgImage: CGImage = loopImage.cgImage()
let image: UIImage = loopImage.image() // alternatively you can use UIImage(loopImage: loopImage)
```

## Documentation

Looping documentation can be found at [znly.github.com/Looping](https://znly.github.com/Looping).

Generated using [SwiftDoc](https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.0.0-beta.3).

## Authors
See [AUTHORS](./AUTHORS) for the list of contributors.

## Credits
Assets used in the example app are taken from:
+ [https://developers.google.com/speed/webp/gallery](https://developers.google.com/speed/webp/gallery)
+ [http://littlesvr.ca/apng/gif_apng_webp.html](http://littlesvr.ca/apng/gif_apng_webp.html)
+ [http://littlesvr.ca/apng/samples.html](http://littlesvr.ca/apng/samples.html)
+ [https://apng.onevcat.com/demo](https://apng.onevcat.com/demo)
+ [https://mathiasbynens.be/demo/animated-webp](https://mathiasbynens.be/demo/animated-webp)
+ [https://github.com/iSparta/iSparta](https://github.com/iSparta/iSparta)
+ [https://nokiatech.github.io/heif/comparison.html](https://nokiatech.github.io/heif/comparison.html)

## License
The Apache License version 2.0 (Apache2) - see [LICENSE](./LICENSE) for more details.

Copyright © 2020 Zenly <hello@zen.ly> [@zenlyapp](https://twitter.com/zenlyapp)
