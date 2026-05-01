import UIKit
import RxSwift
import RxCocoa

final class PostsViewController: UIViewController {

    // MARK: - Layout Constants
    private enum Layout {
        static let estimatedRowHeight: CGFloat = 90
        static let toastHorizontalInset: CGFloat = 32
        static let toastBottomInset: CGFloat = 20
        static let toastHeight: CGFloat = 40
        static let toastCornerRadius: CGFloat = 10
        static let toastFontSize: CGFloat = 13
        static let toastAnimationDelay: TimeInterval = 2.5
        static let toastAnimationDuration: TimeInterval = 0.3
        static let transitionDuration: TimeInterval = 0.3
    }

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let viewModel = PostsViewModel()

    // MARK: - UI
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .none
        tv.backgroundColor = .appSurface
        tv.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.reuseID)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = Layout.estimatedRowHeight
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    private let refreshControl = UIRefreshControl()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.Posts.tabTitle
        view.backgroundColor = .appSurface
        setupNavigationBar()
        setupLayout()
        bindViewModel()
        viewModel.loadPosts()
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Strings.Posts.logoutButton,
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
    }

    private func setupLayout() {
        view.addSubviews(tableView, activityIndicator)
        tableView.refreshControl = refreshControl

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Binding
    private func bindViewModel() {
        viewModel.posts
            .drive(tableView.rx.items(
                cellIdentifier: PostTableViewCell.reuseID,
                cellType: PostTableViewCell.self
            )) { _, model, cell in
                cell.configure(with: model)
            }
            .disposed(by: disposeBag)

        viewModel.isLoading
            .drive(onNext: { [weak self] loading in
                if loading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.refreshControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        viewModel.errorMessage
            .emit(onNext: { [weak self] message in
                self?.showToast(message)
            })
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(PostDisplayModel.self)
            .subscribe(onNext: { [weak self] model in
                self?.viewModel.toggleFavorite(postId: model.id)
            })
            .disposed(by: disposeBag)

        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.loadPosts()
            })
            .disposed(by: disposeBag)

        viewModel.logoutSuccess
            .emit(onNext: { [weak self] in self?.performLogout() })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: Strings.Posts.logoutAlertTitle,
            message: Strings.Posts.logoutAlertMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.Posts.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: Strings.Posts.logoutButton, style: .destructive) { [weak self] _ in
            self?.viewModel.logoutTap.accept(())
        })
        present(alert, animated: true)
    }

    private func performLogout() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let window = appDelegate.window else { return }
        let nav = UINavigationController(rootViewController: LoginViewController())
        window.rootViewController = nav
        UIView.transition(with: window, duration: Layout.transitionDuration, options: .transitionCrossDissolve, animations: nil)
    }

    // MARK: - Toast
    private func showToast(_ message: String) {
        let toast = UILabel()
        toast.text = message
        toast.textColor = .white
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        toast.font = .systemFont(ofSize: Layout.toastFontSize)
        toast.textAlignment = .center
        toast.layer.cornerRadius = Layout.toastCornerRadius
        toast.layer.masksToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.toastHorizontalInset),
            toast.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.toastHorizontalInset),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.toastBottomInset),
            toast.heightAnchor.constraint(equalToConstant: Layout.toastHeight)
        ])

        UIView.animate(
            withDuration: Layout.toastAnimationDuration,
            delay: Layout.toastAnimationDelay,
            options: .curveEaseOut,
            animations: { toast.alpha = 0 },
            completion: { _ in toast.removeFromSuperview() }
        )
    }
}
