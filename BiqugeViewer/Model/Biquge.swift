//
//  Api.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/29.
//

import Foundation
import Alamofire
import SwiftSoup

/// 笔趣阁
enum BiqugeApi: Api {
    case homeRecommend
    case chapterList(bookId: String, page: Int)
    case bookContent(path: String)
    case searchBooks(keyword: String, page: Int)
    
    static var host: String { "https://m.biquge.biz" }
    
    static func coverUrl(id: String) -> String {
        guard id.count > 3 else { return "" }
        let endIndex = id.index(id.startIndex, offsetBy: id.count - 3)
        return "https://www.biquge.biz/files/article/image/\(String(id[..<endIndex]))/\(id)/\(id)s.jpg"
    }
    
    var path: String {
        switch self {
        case .homeRecommend:
            return "/"
        case let .chapterList(bookId, page):
            guard bookId.count > 3 else { return "" }
            let endIndex = bookId.index(bookId.startIndex, offsetBy: bookId.count - 3)
            return "/\(String(bookId[..<endIndex]))/\(bookId)/".appending(page > 1 ? "index_\(page).html" : "")
        case let .bookContent(path):
            return path
        case .searchBooks:
            return "/search.php"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .homeRecommend,
             .chapterList,
             .bookContent:
            return nil
        case let .searchBooks(keyword, page):
            return ["q": keyword, "p": page]
        }
    }
    
    var responseEncoding: String.Encoding {
        switch self {
        case .homeRecommend, .chapterList, .bookContent:
            return String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
        default:
            return .utf8
        }
    }
}

struct BiqugeRecommendHandler: HtmlHandler {
    typealias Content = [HomeRecommend]
    
    func handle(html: String, api: Api) throws -> [HomeRecommend] {
        let doc = try SwiftSoup.parse(html)
        let elements = try doc.select("div.article")
        var recommends: [HomeRecommend] = []
        for element in elements {
            let title = try getTitle(element: element)
            guard let block = try element.select("div.block").first() else { continue }
            let mainBook = try getMainBook(element: block)
            let books = try getBooks(element: block)
            recommends.append(HomeRecommend(category: title, mainBook: mainBook, books: books))
        }
        return recommends
    }
    
    private func getTitle(element: Element) throws -> String {
        return try element.select("h2.title").select("span").first()?.text() ?? ""
    }
    
    private func getMainBook(element: Element) throws -> HomeRecommend.BookInfo? {
        guard let div = try element.select("div.block_txt").first() else { return nil }
        guard let img = try element.select("div.block_img").select("a").first() else { return nil }
        let id = try img.attr("href").components(separatedBy: "/").last(where: { !$0.isEmpty }) ?? ""
        var title: String?
        var author: String?
        var introduce: String?
        for element in div.children() {
            if element.tagName() == "h2" {
                title = try element.text()
            } else if element.tagName() == "p" {
                if !element.children().isEmpty() {
                    let text = try element.text()
                    if !text.isEmpty {
                        introduce = text
                    }
                } else {
                    author = try element.text().replacingOccurrences(of: "作者：", with: "")
                }
            }
        }
        return HomeRecommend.BookInfo(id: id, title: title ?? "", author: author ?? "", introduce: introduce ?? "")
    }
    
    private func getBooks(element: Element) throws -> [HomeRecommend.BookInfo] {
        guard let list = try element.select("ul").first()?.select("li") else { return [] }
        var results: [HomeRecommend.BookInfo] = []
        for item in list {
            let nodes = item.getChildNodes()
            var id: String = ""
            var title: String = ""
            var author: String = ""
            if let node = nodes.first as? Element, node.tagName() == "a" {
                id = try node.attr("href").components(separatedBy: "/").last(where: { !$0.isEmpty }) ?? ""
                title = try node.text()
            }
            if let node = nodes.last as? TextNode {
                author = node.text().replacingOccurrences(of: "/", with: "")
            }
            if !id.isEmpty {
                results.append(HomeRecommend.BookInfo(id: id, title: title, author: author, introduce: nil))
            }
        }
        return results
    }
}

struct BiqugeBookInfoHandler: HtmlHandler {
    typealias Content = BookInfo
    
    func handle(html: String, api: Api) throws -> BookInfo {
        let doc = try SwiftSoup.parse(html)
        let title = try getTitle(document: doc)
        let (author, state) = try getAuthorAndState(document: doc)
        let introduce = try getIntroduce(document: doc)
        let pages = try getPageList(document: doc)
        let chapters = try getChapters(document: doc)
        var id: String = ""
        if case let BiqugeApi.chapterList(bookId, _) = api {
            id = bookId
        }
        return BookInfo(id: id,
                        title: title,
                        author: author,
                        category: state,
                        introduce: introduce,
                        pageNameList: pages,
                        chapters: chapters)
    }
    
    private func getTitle(document: Document) throws -> String {
        return try document.getElementById("bqgmb_h1")?.text() ?? ""
    }
    
    private func getAuthorAndState(document: Document) throws -> (String, String) {
        let elements = try document.select("div.block_txt2").select("p")
        var author = ""
        var state = ""
        for element in elements {
            let text = try element.text()
            if text.hasPrefix("作者：") {
                author = text.replacingOccurrences(of: "作者：", with: "")
            } else if text.hasPrefix("状态：") {
                state = text.replacingOccurrences(of: "状态：", with: "")
            }
        }
        return (author, state)
    }
    
    private func getIntroduce(document: Document) throws -> String {
        return try document.select("div.intro_info").first()?.text() ?? ""
    }
    
    private func getPageList(document: Document) throws -> [String] {
        guard let options = try document.select("div.listpage").select("span.middle").select("select").first()?.select("option") else {
            return []
        }
        var results: [String] = []
        for option in options {
            results.append(try option.text())
        }
        return results
    }
    
    private func getChapters(document: Document) throws -> [BookInfo.ChapterItem] {
        guard let list = try document.select("ul.chapter").last() else {
            throw NSError(domain: "Chapter list not found", code: -999, userInfo: nil)
        }
        var result: [BookInfo.ChapterItem] = []
        for child in list.children() {
            guard child.tagName() == "li" else { continue }
            guard let link = try? child.getElementsByTag("a").first() else { continue }
            result.append(BookInfo.ChapterItem(title: try link.text(), link: try link.attr("href")))
        }
        return result
    }
}

struct BiqugeBookChapterHandler: HtmlHandler {
    typealias Content = BookChapter
    
    func handle(html: String, api: Api) throws -> BookChapter {
        let doc = try SwiftSoup.parse(html)
        let title = try getTitle(document: doc)
        let nextChapterLink = try getNextChapterLink(document: doc)
        let content = try getContent(document: doc)
        var link: String = ""
        if case let BiqugeApi.bookContent(path) = api {
            link = path
        }
        return BookChapter(link: link, html: html, title: title, content: content, nextChapterLink: nextChapterLink)
    }
    
    private func getTitle(document: Document) throws -> String {
        return try document.getElementById("nr_title")?.text() ?? ""
    }
    
    private func getNextChapterLink(document: Document) throws -> String? {
        guard let element = try document.select("td.next_chapter").select("a.jump-chapter-links").first() else {
            return nil
        }
        let link = try element.attr("href")
        return link.contains("dulaiduapp.com") ? nil : link
    }
    
    private func getContent(document: Document) throws -> String {
        guard let div = try document.select("div#nr").first() else {
            throw NSError(domain: "Book content not found", code: -999, userInfo: nil)
        }
        var text = ""
        var nodeStack: [Node] = div.getChildNodes().reversed()
        while !nodeStack.isEmpty {
            let node = nodeStack.removeLast()
            if let textNode = node as? TextNode {
                text.append(textNode.text().replacingOccurrences(of: "&nbsp;", with: " "))
            } else if let element = node as? Element {
                if element.tagName() == "br" {
                    text.append("\n")
                } else {
                    nodeStack.append(contentsOf: element.getChildNodes().reversed())
                }
            }
        }
        return text
    }
}

struct BiqugeSearchResultHandler: HtmlHandler {
    typealias Content = ([BookInfo], Bool)
    
    func handle(html: String, api: Api) throws -> ([BookInfo], Bool) {
        let doc = try SwiftSoup.parse(html)
        let items = try doc.select("div.result-item")
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
        if let titleElement = try item.select("a.result-game-item-title-link").first() {
            title = try titleElement.text()
            id = try titleElement.attr("href").components(separatedBy: "/").last(where: { !$0.isEmpty }) ?? ""
        }
        let introduce = try item.select("p.result-game-item-desc").first()?.text() ?? ""
        var author: String = ""
        var category: String = ""
        if let div = try item.select("div.result-game-item-info").first() {
            func getText(element: Element) throws -> String {
                guard element.children().count >= 2 else { return "" }
                return try element.child(1).text()
            }
            let children = div.children()
            if children.count > 1 {
                author = try getText(element: children[0])
            }
            if children.count > 2 {
                category = try getText(element: children[1])
            }
        }
        return BookInfo(id: id,
                        title: title,
                        author: author,
                        category: category,
                        introduce: introduce)
    }
    
    private func getIsEnd(document: Document) throws -> Bool {
        guard let node = try document.select("div.search-result-page-main").first()?.getChildNodes().last as? TextNode else {
            return true
        }
        let text = node.text()
        let regx = try NSRegularExpression(pattern: "当前第(.+)页.+总共(.+)页", options: .caseInsensitive)
        let matches = regx.matches(in: text, options: .reportCompletion, range: NSRange(location: 0, length: text.count))
        if let match = matches.first, match.numberOfRanges == 3 {
            guard let range1 = Range<String.Index>(match.range(at: 1), in: text),
                  let range2 = Range<String.Index>(match.range(at: 2), in: text) else { return true }
            return String(text[range1]) == String(text[range2])
        }
        return true
    }
}
