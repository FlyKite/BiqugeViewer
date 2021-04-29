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

struct CangShuNovelInfoHandler: HtmlHandler {
    
    typealias Content = NovelInfo
    
    func handle(html: String, api: Api) throws -> NovelInfo {
        let doc = try SwiftSoup.parse(html)
        let title = try getTitle(document: doc)
        let author = try getAuthor(document: doc)
        let introduce = try getIntroduce(document: doc)
        let cover = try getCoverUrl(document: doc)
        let chapters = try getChapters(document: doc)
        var id: String = ""
        if case let CangShuApi.bookChapters(bookId) = api {
            id = bookId
        }
        return NovelInfo(id: id,
                         title: title,
                         author: author,
                         state: "",
                         introduce: introduce,
                         coverUrl: cover,
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
    
    private func getCoverUrl(document: Document) throws -> String {
        return try document.getElementById("book_info")?.select("img").first()?.attr("src") ?? ""
    }
    
    private func getChapters(document: Document) throws -> [NovelChapter] {
        guard let list = try document.select("ul.chapter").last() else {
            throw NSError(domain: "Chapter list not found", code: -999, userInfo: nil)
        }
        var result: [NovelChapter] = []
        for child in list.children() {
            guard child.tagName() == "li" else { continue }
            guard let link = try? child.getElementsByTag("a").first() else { continue }
            result.append(NovelChapter(title: try link.text(), link: try link.attr("href")))
        }
        return result
    }
}
