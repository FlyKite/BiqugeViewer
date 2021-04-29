//
//  Network.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/20.
//

import Foundation
import Alamofire

protocol Api: URLRequestConvertible {
    static var host: String { get }
    var path: String { get }
    var parameters: Parameters? { get }
}

enum BiqugeApi: Api {
    case homeRecommend
    case chapterList(novelId: String, page: Int)
    case novelContent(path: String)
    case searchBooks(keyword: String, page: Int)
    
    static var host: String { "https://m.biquge.com.cn" }
    
    var path: String {
        switch self {
        case .homeRecommend:
            return "/"
        case let .chapterList(novelId, page):
            return "/book/\(novelId)/".appending(page > 1 ? "index_\(page).html" : "")
        case let .novelContent(path):
            return path
        case .searchBooks:
            return "/search.php"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .homeRecommend,
             .chapterList,
             .novelContent:
            return nil
        case let .searchBooks(keyword, page):
            return ["q": keyword, "p": page]
        }
    }
}

extension BiqugeApi {
    func asURLRequest() throws -> URLRequest {
        let host = type(of: self).host
        let path = self.path
        guard let url = URL(string: "\(host)\(path)") else {
            throw NSError(domain: "Could not convert to URL",
                          code: -999,
                          userInfo: ["host": host, "path": path])
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request = try URLEncoding().encode(request, with: parameters)
        return request
    }
}

class Network {
    static func request<T>(_ api: BiqugeApi,
                           htmlHandler: @escaping (String) throws -> T,
                           completion: @escaping (Result<T, Error>) -> Void) {
        let task = AF.request(api).responseString { (response) in
            switch response.result {
            case let .success(html):
                DispatchQueue.global().async {
                    let result: Result<T, Error>
                    do {
                        result = .success(try htmlHandler(html))
                    } catch {
                        result = .failure(error)
                    }
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
