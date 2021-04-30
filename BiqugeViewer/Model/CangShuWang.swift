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
enum CangShuApi: Api {
    case bookChapters(bookId: String)
    case searchBooks(keyword: String, page: Int)
    
    static var host: String { "https://www.99csw.com" }
    
    static func coverUrl(id: String) -> String {
        return "\(host)/book/cover.pic/cover_\(id).jpg"
    }
    
    var path: String {
        switch self {
        case let .bookChapters(bookId):
            return "/book/\(bookId)/index.htm"
        case .searchBooks:
            return "/book/search.php"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .bookChapters:
            return nil
        case let .searchBooks(keyword, page):
            return ["type": "all", "keyword": keyword, "page": page]
        }
    }
}

struct CangShuSearchResultHandler: HtmlHandler {
    typealias Content = ([BookInfo], Bool)
    
    func handle(html: String, api: Api) throws -> ([BookInfo], Bool) {
        let doc = try SwiftSoup.parse(html)
        let items = try doc.select("ul.list_box").select("li")
        var results: [BookInfo] = []
        for item in items {
            results.append(try handle(item: item))
        }
        let isEnd = try getIsEnd(document: doc)
        return (results, isEnd)
    }
    
    private func handle(item: Element) throws -> BookInfo {
        var id: String = ""
        var title: String = ""
        if let titleElement = try item.select("a").first() {
            title = try titleElement.text()
            id = try titleElement.attr("href").replacingOccurrences(of: "/book/", with: "").replacingOccurrences(of: "/index.htm", with: "")
        }
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
        return BookInfo(id: id,
                        title: title,
                        author: author,
                        category: category,
                        introduce: introduce)
    }
    
    private func getIsEnd(document: Document) throws -> Bool {
        guard let node = try document.select("div.page").last() else {
            return true
        }
        return try node.select("a.next").last() == nil
    }
}

struct CangShuBookInfoHandler: HtmlHandler {
    
    typealias Content = BookInfo
    
    func handle(html: String, api: Api) throws -> BookInfo {
        let doc = try SwiftSoup.parse(html)
        let title = try getTitle(document: doc)
        let author = try getAuthor(document: doc)
        let introduce = try getIntroduce(document: doc)
        let chapters = try getChapters(document: doc)
        var id: String = ""
        if case let CangShuApi.bookChapters(bookId) = api {
            id = bookId
        }
        return BookInfo(id: id,
                        title: title,
                        author: author,
                        category: "",
                        introduce: introduce,
                        pageNameList: [],
                        chapters: chapters)
    }
    
    private func getTitle(document: Document) throws -> String {
        return try document.getElementById("book_info")?.select("h2").first()?.text() ?? ""
    }
    
    private func getAuthor(document: Document) throws -> String {
        return try document.getElementById("book_info")?.select("h4").first()?.select("a").first()?.text() ?? ""
    }
    
    private func getIntroduce(document: Document) throws -> String {
        return try document.select("div.intro").first()?.text() ?? ""
    }
    
    private func getChapters(document: Document) throws -> [BookInfo.ChapterItem] {
        guard let list = try document.select("dl#dir").last() else {
            throw NSError(domain: "Chapter list not found", code: -999, userInfo: nil)
        }
        var result: [BookInfo.ChapterItem] = []
        for child in list.children() {
            guard child.tagName() == "dd" else { continue }
            guard let link = try? child.getElementsByTag("a").first() else { continue }
            result.append(BookInfo.ChapterItem(title: try link.text(), link: try link.attr("href")))
        }
        return result
    }
}
