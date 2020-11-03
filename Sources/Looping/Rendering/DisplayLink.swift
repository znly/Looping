import Foundation

import class QuartzCore.CADisplayLink
import func QuartzCore.CACurrentMediaTime

private protocol Proxifiable: class {
    func proxy()
}

private class WeakTargetProxy {
    private weak var target: Proxifiable?

    init(target: Proxifiable) {
        self.target = target
    }

    @objc func proxy() {
        target?.proxy()
    }
}

final class DisplayLink {
    private var isInitiated: Bool
    private let fire: (TimeInterval) -> Void

    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: WeakTargetProxy(target: self), selector: #selector(WeakTargetProxy.proxy))
        displayLink.add(to: .main, forMode: .common)
        displayLink.isPaused = true
        displayLink.preferredFramesPerSecond = preferredFramesPerSecond
        isInitiated = true
        return displayLink
    }()

    var preferredFramesPerSecond: Int = 0 {
        didSet {
            if isInitiated {
                displayLink.preferredFramesPerSecond = preferredFramesPerSecond
            }
        }
    }

    var isPaused: Bool {
        set { displayLink.isPaused = newValue }
        get { return displayLink.isPaused }
    }

    init(_ fire: @escaping (TimeInterval) -> Void) {
        self.fire = fire
        isInitiated = false
    }

    deinit {
        if isInitiated {
            displayLink.invalidate()
        }
    }
}

extension DisplayLink: Proxifiable {

    fileprivate func proxy() {
        fire(displayLink.targetTimestamp - displayLink.timestamp)
    }
}
