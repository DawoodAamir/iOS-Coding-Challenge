import Foundation
import Alamofire
import RxSwift

protocol NetworkManagerProtocol {
    func fetchPosts() -> Single<[PostDTO]>
}

final class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()
    private init() {}

    func fetchPosts() -> Single<[PostDTO]> {
        Single.create { single in
            let req = AF.request(APIEndpoints.posts)
                .validate()
                .responseDecodable(of: [PostDTO].self) { response in
                    switch response.result {
                    case .success(let posts): single(.success(posts))
                    case .failure(let error): single(.failure(error))
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
}
