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

    private let disposeBag = DisposeBag()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String>()

    init() {
        isLoading = loadingRelay.asDriver()
        errorMessage = errorRelay.asSignal()

        // Observe Realm results reactively with RxRealm
        let realmResults = RealmManager.shared.allPosts()
        posts = Observable.collection(from: realmResults)
            .map { Array($0) }
            .asDriver(onErrorJustReturn: [])
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
                    // Cached data already drives the table; surface a subtle banner only
                    self?.errorRelay.accept("Could not refresh — showing cached posts")
                }
            )
            .disposed(by: disposeBag)
    }

    func toggleFavorite(postId: Int) {
        RealmManager.shared.toggleFavorite(postId: postId)
    }
}
