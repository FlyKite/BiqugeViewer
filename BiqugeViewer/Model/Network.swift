//
//  Network.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/20.
//

import Foundation
import Alamofire

class Network {
    static func getPage(completion: ((Result<String, Error>) -> Void)?) {
        let url = "https://m.biquge.com.cn/book/32883/196858.html"
        let task = AF.request(url).responseString { (response) in
            switch response.result {
            case let .success(html):
                completion?(.success(html))
            case let .failure(error):
                completion?(.failure(error))
            }
        }
        task.resume()
    }
    
    static let host: String = "https://m.biquge.com.cn"
    
    static func getNovelPage(path: String, completion: ((Result<Novel, Error>) -> Void)?) {
        let url = host.appending(path)
        let task = AF.request(url).responseString { (response) in
            switch response.result {
            case let .success(html):
                DispatchQueue.global().async {
                    let result: Result<Novel, Error>
                    do {
                        let novel = try Novel.handle(from: html, link: path)
                        result = .success(novel)
                    } catch {
                        result = .failure(error)
                    }
                    DispatchQueue.main.async {
                        completion?(result)
                    }
                }
            case let .failure(error):
                completion?(.failure(error))
            }
        }
        task.resume()
    }
}