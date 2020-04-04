import UIKit

extension UIButton {

    open override func draw(_ rect: CGRect) {
        titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .black)
        layer.cornerRadius = 10
        layer.cornerCurve = .continuous
        clipsToBounds = true
    }
}
