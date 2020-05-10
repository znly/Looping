// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Looping",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "Looping", targets: ["Looping"]),
        .library(name: "LoopingWebP", targets: ["LoopingWebP"])
    ],
    targets: [
        .target(name: "Looping", dependencies: [], path: "Sources/Looping"),
        .target(name: "LoopingWebP", dependencies: ["Looping", "WebP"], path: "Sources/LoopingWebP"),
        .target(
            name: "WebP",
            path: "Sources/WebP/libwebp/",
            sources: ["src"],
            publicHeadersPath: "src/webp",
            cSettings: [.headerSearchPath(".")]
        )
    ]
)
