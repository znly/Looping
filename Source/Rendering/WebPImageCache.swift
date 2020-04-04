import UIKit

private extension CGImage {

    var cost: Int {
        return height * width
    }
}

final class WebPImageFrameCache {
    let cacheObject = NSCache<NSString, CGImage>()

    init(image: WebPImage) {
        cacheObject.name = "com.znly.WebPImageFameCache.\(image.uuid)"
        cacheObject.countLimit = image.frameCount
        cacheObject.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }

    deinit {
        cacheObject.removeAllObjects()
    }

    func set(frame: CGImage, forKey key: String) {
        cacheObject.setObject(frame, forKey: key as NSString, cost: frame.cost)
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
