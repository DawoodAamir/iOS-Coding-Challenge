import UIKit
import RxSwift
import RxCocoa

final class FavoritesViewController: UIViewController {

    // MARK: - Layout Constants
    private enum Layout {
        static let estimatedRowHeight: CGFloat = 90
        static let emptyLabelFontSize: CGFloat = 16
    }

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = FavoritesViewModel()

    private var currentPostIds: [Int] = []

    // MARK: - UI
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .none
        tv.backgroundColor = .appSurface
        tv.register(FavoriteTableViewCell.self, forCellReuseIdentifier: FavoriteTableViewCell.reuseID)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = Layout.estimatedRowHeight
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = Strings.Favorites.emptyMessage
        l.numberOfLines = 2
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: Layout.emptyLabelFontSize, weight: .regular)
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.Favorites.tabTitle
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
                self?.currentPostIds = posts.map { $0.id }
                self?.emptyLabel.isHidden = !posts.isEmpty
                self?.tableView.isHidden = posts.isEmpty
            })
            .drive(tableView.rx.items(
                cellIdentifier: FavoriteTableViewCell.reuseID,
                cellType: FavoriteTableViewCell.self
            )) { _, model, cell in
                cell.configure(with: model)
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
        let delete = UIContextualAction(style: .destructive, title: Strings.Favorites.removeAction) { [weak self] _, _, completion in
            guard let self, indexPath.row < self.currentPostIds.count else {
                completion(false)
                return
            }
            let postId = self.currentPostIds[indexPath.row]
            self.viewModel.removeFromFavorites(postId: postId)
            completion(true)
        }
        delete.image = UIImage(systemName: "heart.slash.fill")
        delete.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
