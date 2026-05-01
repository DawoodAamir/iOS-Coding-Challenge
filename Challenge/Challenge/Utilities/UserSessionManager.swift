import Foundation

final class UserSessionManager {
    static let shared = UserSessionManager()
    private init() {}

    private let key = "com.challenge.isLoggedIn"

    var isLoggedIn: Bool {
        UserDefaults.standard.bool(forKey: key)
    }

    func login() {
        UserDefaults.standard.set(true, forKey: key)
    }

    func logout() {
        UserDefaults.standard.set(false, forKey: key)
    }
}
