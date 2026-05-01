import Foundation
import RealmSwift
import RxSwift
import RxRealm

final class RealmManager {
    static let shared = RealmManager()

    private let realm: Realm?

    private init() {
        do {
            realm = try Realm()
        } catch {
            realm = nil
        }
    }

    func savePosts(_ dtos: [PostDTO]) {
        guard let realm else { return }
        let favoriteIds = Set(realm.objects(PostObject.self).filter("isFavorite == true").map { $0.id })
        let objects = dtos.map { $0.toRealmObject(preservingFavorite: favoriteIds.contains($0.id)) }
        try? realm.write {
            realm.add(objects, update: .modified)
        }
    }

    func allPosts() -> Results<PostObject>? {
        realm?.objects(PostObject.self).sorted(byKeyPath: "id")
    }

    func favoritePosts() -> Results<PostObject>? {
        realm?.objects(PostObject.self)
            .filter("isFavorite == true")
            .sorted(byKeyPath: "id")
    }

    func toggleFavorite(postId: Int) {
        guard let realm,
              let post = realm.object(ofType: PostObject.self, forPrimaryKey: postId) else { return }
        try? realm.write {
            post.isFavorite = !post.isFavorite
        }
    }

    func removeFromFavorites(postId: Int) {
        guard let realm,
              let post = realm.object(ofType: PostObject.self, forPrimaryKey: postId) else { return }
        try? realm.write {
            post.isFavorite = false
        }
    }
}
