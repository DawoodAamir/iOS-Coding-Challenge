import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        styleTabBar()
    }

    private func setupTabs() {
        let postsNav = UINavigationController(rootViewController: PostsViewController())
        postsNav.tabBarItem = UITabBarItem(
            title: Strings.Posts.tabTitle,
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )

        let favoritesNav = UINavigationController(rootViewController: FavoritesViewController())
        favoritesNav.tabBarItem = UITabBarItem(
            title: Strings.Favorites.tabTitle,
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )

        viewControllers = [postsNav, favoritesNav]
    }

    private func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .appPrimary
    }
}
