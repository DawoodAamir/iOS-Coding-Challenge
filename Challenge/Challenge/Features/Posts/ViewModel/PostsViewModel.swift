import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

final class PostsViewModel {

    // MARK: - Outputs
    let posts: Driver<[PostDisplayModel]>
    let isLoading: Driver<Bool>
    let errorMessage: Signal<String>
    let logoutSuccess: Signal<Void>

    // MARK: - Inputs
    let logoutTap = PublishRelay<Void>()

    // MARK: - Dependencies
    private let network: NetworkManagerProtocol
    private let realmManager: RealmManagerProtocol
    private let session: UserSessionManagerProtocol

    private let disposeBag = DisposeBag()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()

    init(
        network: NetworkManagerProtocol = NetworkManager.shared,
        realmManager: RealmManagerProtocol = RealmManager.shared,
        session: UserSessionManagerProtocol = UserSessionManager.shared
    ) {
        self.network = network
        self.realmManager = realmManager
        self.session = session

        isLoading = loadingRelay.asDriver()
        errorMessage = errorRelay.asSignal()

        if let realmResults = realmManager.allPosts() {
            posts = Observable.collection(from: realmResults)
                .map { $0.map(PostDisplayModel.init) }
                .asDriver(onErrorJustReturn: [])
        } else {
            posts = .just([])
        }

        logoutSuccess = logoutTap
            .do(onNext: { session.logout() })
            .asSignal(onErrorSignalWith: .empty())
    }

    func loadPosts() {
        loadingRelay.accept(true)
        network.fetchPosts()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] dtos in
                    self?.realmManager.savePosts(dtos)
                    self?.loadingRelay.accept(false)
                },
                onFailure: { [weak self] _ in
                    self?.loadingRelay.accept(false)
                    self?.errorRelay.accept("Could not refresh — showing cached posts")
                }
            )
            .disposed(by: disposeBag)
    }

    func toggleFavorite(postId: Int) {
        realmManager.toggleFavorite(postId: postId)
    }
}
