import Foundation

import class ImageIO.CGImage

final class FrameCache {
    let cacheObject = NSCache<NSString, CGImage>()

    init(image: LoopImage) {
        cacheObject.name = "looping.frameCache.\(image.uuid)"
        cacheObject.countLimit = image.frameCount
    }

    deinit {
        cacheObject.removeAllObjects()
    }

    func set(frame: CGImage, forKey key: String) {
        cacheObject.setObject(frame, forKey: key as NSString)
    }

    func removeImage(forKey key: String) {
        cacheObject.removeObject(forKey: key as NSString)
    }

    func frame(forKey key: String) -> CGImage? {
        return cacheObject.object(forKey: key as NSString)
    }

    @objc func clear() {
        cacheObject.removeAllObjects()
    }
}
