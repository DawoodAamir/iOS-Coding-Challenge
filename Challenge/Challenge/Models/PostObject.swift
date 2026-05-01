import Foundation
import RealmSwift

final class PostObject: Object {
    @Persisted(primaryKey: true) var id: Int = 0
    @Persisted var userId: Int = 0
    @Persisted var title: String = ""
    @Persisted var body: String = ""
    @Persisted var isFavorite: Bool = false
}

struct PostDTO: Decodable {
    let id: Int
    let userId: Int
    let title: String
    let body: String

    func toRealmObject(preservingFavorite isFavorite: Bool = false) -> PostObject {
        let obj = PostObject()
        obj.id = id
        obj.userId = userId
        obj.title = title
        obj.body = body
        obj.isFavorite = isFavorite
        return obj
    }
}
