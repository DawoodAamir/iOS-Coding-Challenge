import Foundation

struct PostDisplayModel {
    let id: Int
    let title: String
    let body: String
    let isFavorite: Bool

    init(_ post: PostObject) {
        id = post.id
        let raw = post.title
        title = raw.prefix(1).uppercased() + raw.dropFirst()
        body = post.body
        isFavorite = post.isFavorite
    }
}
