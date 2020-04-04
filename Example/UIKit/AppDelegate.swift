import UIKit

infix operator .. : MultiplicationPrecedence
@discardableResult func .. <T>(object: T, block: (inout T) -> Void) -> T {
    var object = object
    block(&object)
    return object
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UIStackView.appearance().spacing = 8
        UILabel.appearance().font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .bold)
        UILabel.appearance().adjustsFontSizeToFitWidth = true

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

}
