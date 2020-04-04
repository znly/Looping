import Foundation

import class QuartzCore.CADisplayLink

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
    private var isInitialized: Bool = false
    private let update: (TimeInterval) -> Void

    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: WeakTargetProxy(target: self), selector: #selector(WeakTargetProxy.proxy))
        displayLink.add(to: .main, forMode: RunLoop.Mode.common)
        displayLink.isPaused = true
        self.isInitialized = true
        return displayLink
    }()

    var isPaused: Bool {
        set { displayLink.isPaused = newValue }
        get { return displayLink.isPaused }
    }

    init(_ update: @escaping (TimeInterval) -> Void) {
        self.update = update
    }

    deinit {
        if isInitialized {
            displayLink.invalidate()
        }
    }
}

extension DisplayLink: Proxifiable {

    fileprivate func proxy() {
        update(displayLink.duration)
    }
}
