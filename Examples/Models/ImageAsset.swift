import Foundation
import CoreGraphics

struct ImageAsset: CustomStringConvertible, Hashable {
    let filename: String?

    static let none = ImageAsset(filename: nil)

    enum APNG {
        // Animation
        static let bladerunner = ImageAsset(filename: "bladerunner@2x.png")
        static let clock = ImageAsset(filename: "clock@2x.png")
        static let contact = ImageAsset(filename: "contact@2x.png")
        static let elephant = ImageAsset(filename: "elephant.png")
        static let genevadrive = ImageAsset(filename: "genevadrive.png")
        static let o = ImageAsset(filename: "o.png")
        static let steamengine = ImageAsset(filename: "steamengine.png")
        static let worldcup = ImageAsset(filename: "worldcup@2x.png")

        // Still
        static let tux = ImageAsset(filename: "tux@2x.png")
    }

    enum GIF {
        // Animation
        static let bladerunner = ImageAsset(filename: "bladerunner@2x.gif")
        static let candle = ImageAsset(filename: "candle.gif")
        static let clock = ImageAsset(filename: "clock@2x.gif")
        static let contact = ImageAsset(filename: "contact@2x.gif")
        static let elephant = ImageAsset(filename: "elephant.gif")
        static let genevadrive = ImageAsset(filename: "genevadrive.gif")
        static let o = ImageAsset(filename: "o.gif")
        static let starfield = ImageAsset(filename: "starfield.gif")
        static let steamengine = ImageAsset(filename: "steamengine.gif")
        static let worldcup = ImageAsset(filename: "worldcup@2x.gif")
    }

    enum HEIC {
        // Animation
        static let candle = ImageAsset(filename: "candle.heic")
        static let starfield = ImageAsset(filename: "starfield.heic")

        // Still
        static let street = ImageAsset(filename: "street@3x.heic")
        static let nature = ImageAsset(filename: "nature@3x.heic")
        static let tourist = ImageAsset(filename: "tourist@3x.heic")
    }

    enum WebP {
        // Animation
        static let banana = ImageAsset(filename: "banana@3x.webp")
        static let bladerunner = ImageAsset(filename: "bladerunner@2x.webp")
        static let contact = ImageAsset(filename: "contact@2x.webp")
        static let genevadrive = ImageAsset(filename: "genevadrive.webp")
        static let niancat = ImageAsset(filename: "niancat@2x.webp")
        static let rubixcube = ImageAsset(filename: "rubixcube.webp")
        static let steamengine = ImageAsset(filename: "steamengine.webp")
        static let worldcup = ImageAsset(filename: "worldcup@2x.webp")

        // Still
        static let canyon = ImageAsset(filename: "canyon@2x.webp")
        static let colors = ImageAsset(filename: "colors@2x.webp")
        static let dices = ImageAsset(filename: "dices@2x.webp")
        static let flamethrower = ImageAsset(filename: "flamethrower@2x.webp")
        static let flower = ImageAsset(filename: "flower@2x.webp")
        static let google = ImageAsset(filename: "google@2x.webp")
        static let rapids = ImageAsset(filename: "rapids@2x.webp")
        static let riverbank = ImageAsset(filename: "riverbank@2x.webp")
        static let tree = ImageAsset(filename: "tree@2x.webp")
        static let tux = ImageAsset(filename: "tux@2x.webp")
    }

    static let animations: [ImageAsset] = [
        none,

        APNG.bladerunner,
        APNG.clock,
        APNG.contact,
        APNG.elephant,
        APNG.genevadrive,
        APNG.o,
        APNG.steamengine,
        APNG.worldcup,

        GIF.bladerunner,
        GIF.candle,
        GIF.clock,
        GIF.contact,
        GIF.elephant,
        GIF.genevadrive,
        GIF.o,
        GIF.starfield,
        GIF.steamengine,
        GIF.worldcup,

        HEIC.candle,
        HEIC.starfield,

        WebP.banana,
        WebP.bladerunner,
        WebP.contact,
        WebP.genevadrive,
        WebP.niancat,
        WebP.rubixcube,
        WebP.steamengine,
        WebP.worldcup
    ]

    static let stills: [ImageAsset] = [
        none,

        APNG.tux,

        HEIC.nature,
        HEIC.street,
        HEIC.tourist,

        WebP.canyon,
        WebP.dices,
        WebP.flamethrower,
        WebP.flower,
        WebP.google,
        WebP.rapids,
        WebP.riverbank,
        WebP.tree,
        WebP.tux
    ]

    public var description: String {
        return filename ?? "none"
    }
}
