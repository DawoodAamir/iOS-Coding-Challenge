import Foundation

enum APIEndpoints {
    static let baseURL = "https://jsonplaceholder.typicode.com"
    static var posts: String { baseURL + "/posts" }
    static func comments(postId: Int) -> String { baseURL + "/posts/\(postId)/comments" }
}
