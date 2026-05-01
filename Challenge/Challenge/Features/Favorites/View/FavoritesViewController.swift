import UIKit
import RxSwift
import RxCocoa

final class FavoritesViewController: UIViewController {

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = FavoritesViewModel()

    // Snapshot of current data for swipe-delete indexing
    private var currentPosts: [PostObject] = []

    // MARK: - UI
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .none
        tv.backgroundColor = .appSurface
        tv.register(FavoriteTableViewCell.self, forCellReuseIdentifier: FavoriteTableViewCell.reuseID)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 90
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No favorites yet.\nTap a post to add it."
        l.numberOfLines = 2
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        view.backgroundColor = .appSurface
        setupLayout()
        tableView.delegate = self
        bindViewModel()
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubviews(tableView, emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Binding
    private func bindViewModel() {
        viewModel.favorites
            .do(onNext: { [weak self] posts in
                self?.currentPosts = posts
                self?.emptyLabel.isHidden = !posts.isEmpty
                self?.tableView.isHidden = posts.isEmpty
            })
            .drive(tableView.rx.items(
                cellIdentifier: FavoriteTableViewCell.reuseID,
                cellType: FavoriteTableViewCell.self
            )) { _, post, cell in
                cell.configure(with: post)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate (swipe to delete)
extension FavoritesViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completion in
            guard let self, indexPath.row < self.currentPosts.count else {
                completion(false)
                return
            }
            let postId = self.currentPosts[indexPath.row].id
            self.viewModel.removeFromFavorites(postId: postId)
            completion(true)
        }
        delete.image = UIImage(systemName: "heart.slash.fill")
        delete.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
