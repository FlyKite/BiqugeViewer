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
    var responseEncoding: String.Encoding { get }
}

protocol ApiResponse {
    static func parse(html: String) throws -> Self
}

protocol ApiV2: URLRequestConvertible {
    associatedtype ResponseType: ApiResponse
    var path: String { get }
    var parameters: Parameters? { get }
    var method: HTTPMethod { get }
    var responseEncoding: String.Encoding { get }
}

protocol HtmlHandler {
    associatedtype Content
    func handle(html: String, api: Api) throws -> Content
}

class Network {
    static func request<Handler: HtmlHandler>(_ api: Api,
                                              handler: Handler,
                                              completion: @escaping (Result<Handler.Content, Error>) -> Void) {
        let task = AF.request(api).responseString(queue: .global(), encoding: api.responseEncoding) { (response) in
            let result: Result<Handler.Content, Error>
            switch response.result {
            case let .success(html):
                do {
                    result = .success(try handler.handle(html: html, api: api))
                } catch {
                    result = .failure(error)
                }
            case let .failure(error):
                result = .failure(error)
            }
            DispatchQueue.main.async {
                completion(result)
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
