import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

final class PostsViewModel {

    // MARK: - Outputs
    let posts: Driver<[PostObject]>
    let isLoading: Driver<Bool>
    let errorMessage: Signal<String>
    let logoutSuccess: Signal<Void>

    // MARK: - Inputs
    let logoutTap = PublishRelay<Void>()

    private let disposeBag = DisposeBag()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()

    init() {
        isLoading = loadingRelay.asDriver()
        errorMessage = errorRelay.asSignal()

        if let realmResults = RealmManager.shared.allPosts() {
            posts = Observable.collection(from: realmResults)
                .map { Array($0) }
                .asDriver(onErrorJustReturn: [])
        } else {
            posts = .just([])
        }

        logoutSuccess = logoutTap
            .do(onNext: { UserSessionManager.shared.logout() })
            .asSignal(onErrorSignalWith: .empty())
    }

    func loadPosts() {
        loadingRelay.accept(true)
        NetworkManager.shared.fetchPosts()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] dtos in
                    RealmManager.shared.savePosts(dtos)
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
        RealmManager.shared.toggleFavorite(postId: postId)
    }
}
