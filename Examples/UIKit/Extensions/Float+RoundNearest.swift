import Foundation

extension Float {

    func rounded(nearest: Float) -> Float {
        let n = 1 / nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }
}
