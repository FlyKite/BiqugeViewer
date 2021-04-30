//
//  Network.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/20.
//

import Foundation
import Alamofire
import SwiftSoup

enum WebSourceType: String, CaseIterable {
    case biquge
    case cangshuwang
}

protocol WebSource: Api {
    func bookCoverUrl(bookId: String) -> String
}

protocol Api: URLRequestConvertible {
    static var host: String { get }
    var path: String { get }
    var parameters: Parameters? { get }
}

protocol HtmlHandler {
    associatedtype Content
    func handle(html: String, api: Api) throws -> Content
}

class Network {
    static func request<Handler: HtmlHandler>(_ api: Api,
                                              handler: Handler,
                                              completion: @escaping (Result<Handler.Content, Error>) -> Void) {
        let task = AF.request(api).responseString(encoding: .utf8) { (response) in
            switch response.result {
            case let .success(html):
                DispatchQueue.global().async {
                    let result: Result<Handler.Content, Error>
                    do {
                        result = .success(try handler.handle(html: html, api: api))
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

extension Api {
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
