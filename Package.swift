// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "WebPImage",
    platforms: [
        .iOS(.v8),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "WebPImage", targets: ["WebPImage"])
    ],
    dependencies: [
        .package(url: "https://github.com/znly/WebP.git", .exact("1.1.0"))
    ],
    targets: [
        .target(name: "WebPImage", dependencies: ["WebP"], path: "Source")
//        .testTarget(name: "WebPImageTests", dependencies: ["WebPImage"])
    ]
)
