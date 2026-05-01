import Foundation
import RealmSwift
import RxSwift
import RxRealm

final class RealmManager {
    static let shared = RealmManager()
    private init() {}

    var realm: Realm {
        // Force-try is acceptable here — Realm only throws on misconfiguration, not runtime failures
        return try! Realm()
    }

    func savePosts(_ dtos: [PostDTO]) {
        let realm = self.realm
        let existing = realm.objects(PostObject.self)
        let favoriteIds = Set(existing.filter("isFavorite == true").map { $0.id })

        let objects = dtos.map { $0.toRealmObject(preservingFavorite: favoriteIds.contains($0.id)) }
        try? realm.write {
            realm.add(objects, update: .modified)
        }
    }

    func allPosts() -> Results<PostObject> {
        realm.objects(PostObject.self).sorted(byKeyPath: "id")
    }

    func favoritePosts() -> Results<PostObject> {
        realm.objects(PostObject.self)
            .filter("isFavorite == true")
            .sorted(byKeyPath: "id")
    }

    func toggleFavorite(postId: Int) {
        let realm = self.realm
        guard let post = realm.object(ofType: PostObject.self, forPrimaryKey: postId) else { return }
        try? realm.write {
            post.isFavorite = !post.isFavorite
        }
    }

    func removeFromFavorites(postId: Int) {
        let realm = self.realm
        guard let post = realm.object(ofType: PostObject.self, forPrimaryKey: postId) else { return }
        try? realm.write {
            post.isFavorite = false
        }
    }
}
