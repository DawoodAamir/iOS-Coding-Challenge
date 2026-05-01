import Foundation

enum APIEndpoints {
    static let baseURL = "https://jsonplaceholder.typicode.com"
    static var posts: String { baseURL + "/posts" }
}
