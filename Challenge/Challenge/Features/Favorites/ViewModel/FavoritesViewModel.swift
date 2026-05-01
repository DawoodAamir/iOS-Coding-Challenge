import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

final class FavoritesViewModel {

    let favorites: Driver<[PostObject]>

    init() {
        let results = RealmManager.shared.favoritePosts()
        favorites = Observable.collection(from: results)
            .map { Array($0) }
            .asDriver(onErrorJustReturn: [])
    }

    func removeFromFavorites(postId: Int) {
        RealmManager.shared.removeFromFavorites(postId: postId)
    }
}
