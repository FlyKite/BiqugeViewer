//
//  CangShuWang.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/29.
//

import Foundation
import Alamofire
import SwiftSoup

/// 99藏书网
enum CangShuApi {
    case searchBooks(keyword: String, page: Int)
    
    static var host: String { "https://www.99csw.com" }
    
    var path: String {
        switch self {
        case .searchBooks:
            return "/book/search.php"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .searchBooks(keyword, page):
            return ["type": "all", "keyword": keyword, "page": page]
        }
    }
}

struct CangShuHandler: HtmlHandler {
    typealias Content = ([SearchNovelInfo], Bool)
    
    func handle(html: String, api: Api) throws -> ([SearchNovelInfo], Bool) {
        let doc = try SwiftSoup.parse(html)
        let items = try doc.select("ul.list_box").select("li")
        var results: [SearchNovelInfo] = []
        for item in items {
            results.append(try handle(item: item))
        }
        let isEnd = try getIsEnd(document: doc)
        return (results, isEnd)
    }
    
    private func handle(item: Element) throws -> SearchNovelInfo {
        var id: String = ""
        var title: String = ""
        if let titleElement = try item.select("a").first() {
            title = try titleElement.text()
            id = try titleElement.attr("href").replacingOccurrences(of: "/book/", with: "").replacingOccurrences(of: "/index.htm", with: "")
        }
        let coverUrl = try item.select("img").first()?.attr("src") ?? ""
        let introduce = try item.select("div.intro").first()?.text() ?? ""
        var author: String = ""
        var category: String = ""
        let blocks = try item.select("h4")
        if blocks.count > 0 {
            author = try blocks[0].select("a").first()?.text() ?? ""
        }
        if blocks.count > 1 {
            category = try blocks[1].select("a").first()?.text() ?? ""
        }
        return SearchNovelInfo(id: id,
                               coverUrl: coverUrl,
                               title: title,
                               author: author,
                               category: category,
                               introduce: introduce,
                               latestChapterTitle: "",
                               latestChapterTime: "")
    }
    
    private func getIsEnd(document: Document) throws -> Bool {
        guard let node = try document.select("div.page").last() else {
            return true
        }
        return try node.select("a.next").last() != nil
    }
}
