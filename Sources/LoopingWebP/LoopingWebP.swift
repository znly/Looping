import Foundation

public enum LoopingWebP {

    public static func enable() {
        WebPCodec.register()
    }
}
