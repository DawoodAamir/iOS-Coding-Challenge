import Foundation

enum Strings {
    enum Login {
        static let title = "Welcome Back"
        static let subtitle = "Sign in to continue"
        static let emailPlaceholder = "Email address"
        static let passwordPlaceholder = "Password (8–15 characters)"
        static let emailError = "Enter a valid email address"
        static let passwordError = "Password must be 8–15 characters"
        static let signIn = "Sign In"
    }

    enum Posts {
        static let tabTitle = "Posts"
        static let logoutButton = "Logout"
        static let logoutAlertTitle = "Logout"
        static let logoutAlertMessage = "Are you sure?"
        static let cancel = "Cancel"
        static let refreshError = "Could not refresh — showing cached posts"
    }

    enum Favorites {
        static let tabTitle = "Favorites"
        static let emptyMessage = "No favorites yet.\nTap a post to add it."
        static let removeAction = "Remove"
    }
}
