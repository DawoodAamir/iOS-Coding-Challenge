import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

final class FavoritesViewModel {

    let favorites: Driver<[PostObject]>

    private let realmManager: RealmManagerProtocol

    init(realmManager: RealmManagerProtocol = RealmManager.shared) {
        self.realmManager = realmManager

        if let results = realmManager.favoritePosts() {
            favorites = Observable.collection(from: results)
                .map { Array($0) }
                .asDriver(onErrorJustReturn: [])
        } else {
            favorites = .just([])
        }
    }

    func removeFromFavorites(postId: Int) {
        realmManager.removeFromFavorites(postId: postId)
    }
}
