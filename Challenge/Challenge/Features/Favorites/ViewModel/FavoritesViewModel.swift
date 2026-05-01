import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

final class FavoritesViewModel {

    let favorites: Driver<[PostDisplayModel]>

    private let realmManager: FavoritesStorageProtocol

    init(realmManager: FavoritesStorageProtocol = RealmManager.shared) {
        self.realmManager = realmManager

        if let results = realmManager.favoritePosts() {
            favorites = Observable.collection(from: results)
                .map { $0.map(PostDisplayModel.init) }
                .asDriver(onErrorJustReturn: [])
        } else {
            favorites = .just([])
        }
    }

    func removeFromFavorites(postId: Int) {
        realmManager.removeFromFavorites(postId: postId)
    }
}
