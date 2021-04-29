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

struct BiqugeRecommendHandler: HtmlHandler {
    typealias Content = [HomeRecommend]
    
    func handle(html: String, api: Api) throws -> [HomeRecommend] {
        let doc = try SwiftSoup.parse(html)
        let elements = try doc.select("div.article")
        var recommends: [HomeRecommend] = []
        for element in elements {
            let title = try getTitle(element: element)
            guard let block = try element.select("div.block").first() else { continue }
            let mainNovel = try getMainNovel(element: block)
            let novels = try getNovels(element: block)
            recommends.append(HomeRecommend(category: title, mainNovel: mainNovel, novels: novels))
        }
        return recommends
    }
    
    private func getTitle(element: Element) throws -> String {
        return try element.select("h2.title").select("span").first()?.text() ?? ""
    }
    
    private func getMainNovel(element: Element) throws -> HomeRecommend.RecommendNovel? {
        guard let div = try element.select("div.block_txt").first() else { return nil }
        guard let img = try element.select("div.block_img").select("a").first() else { return nil }
        let id = try img.attr("href").replacingOccurrences(of: "book", with: "").replacingOccurrences(of: "/", with: "")
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
        return HomeRecommend.RecommendNovel(id: id, title: title ?? "", author: author ?? "", introduce: introduce ?? "")
    }
    
    private func getNovels(element: Element) throws -> [HomeRecommend.RecommendNovel] {
        guard let list = try element.select("ul").first()?.select("li") else { return [] }
        var results: [HomeRecommend.RecommendNovel] = []
        for item in list {
            let nodes = item.getChildNodes()
            var id: String = ""
            var title: String = ""
            var author: String = ""
            if let node = nodes.first as? Element, node.tagName() == "a" {
                id = try node.attr("href").replacingOccurrences(of: "book", with: "").replacingOccurrences(of: "/", with: "")
                title = try node.text()
            }
            if let node = nodes.last as? TextNode {
                author = node.text().replacingOccurrences(of: "/", with: "")
            }
            if !id.isEmpty {
                results.append(HomeRecommend.RecommendNovel(id: id, title: title, author: author, introduce: nil))
            }
        }
        return results
    }
}

struct BiqugeNovelInfoHandler: HtmlHandler {
    typealias Content = NovelInfo
    
    func handle(html: String, api: Api) throws -> NovelInfo {
        let doc = try SwiftSoup.parse(html)
        let title = try getTitle(document: doc)
        let (author, state) = try getAuthorAndState(document: doc)
        let introduce = try getIntroduce(document: doc)
        let cover = try getCoverUrl(document: doc)
        let pages = try getPageList(document: doc)
        let chapters = try BiqugeNovelChapterHandler().handle(from: doc)
        var id: String = ""
        if case let BiqugeApi.chapterList(novelId, _) = api {
            id = novelId
        }
        return NovelInfo(id: id,
                         title: title,
                         author: author,
                         state: state,
                         introduce: introduce,
                         coverUrl: cover,
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
    
    private func getCoverUrl(document: Document) throws -> String {
        return try document.select("div.block_img2").select("img").first()?.attr("src") ?? ""
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
}

struct BiqugeNovelChapterHandler: HtmlHandler {
    typealias Content = [NovelChapter]
    
    func handle(html: String, api: Api) throws -> [NovelChapter] {
        let doc = try SwiftSoup.parse(html)
        return try handle(from: doc)
    }
    
    func handle(from doc: Document) throws -> [NovelChapter] {
        guard let list = try doc.select("ul.chapter").last() else {
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

struct BiqugeNovelHandler: HtmlHandler {
    typealias Content = Novel
    
    func handle(html: String, api: Api) throws -> Novel {
        let doc = try SwiftSoup.parse(html)
        let title = try getTitle(document: doc)
        let nextChapterLink = try getNextChapterLink(document: doc)
        let content = try getContent(document: doc)
        var link: String = ""
        if case let BiqugeApi.novelContent(path) = api {
            link = path
        }
        return Novel(link: link, html: html, title: title, content: content, nextChapterLink: nextChapterLink)
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
            throw NSError(domain: "Novel content not found", code: -999, userInfo: nil)
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
    typealias Content = ([SearchNovelInfo], Bool)
    
    func handle(html: String, api: Api) throws -> ([SearchNovelInfo], Bool) {
        let doc = try SwiftSoup.parse(html)
        let items = try doc.select("div.result-item")
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
        if let titleElement = try item.select("a.result-game-item-title-link").first() {
            title = try titleElement.text()
            id = try titleElement.attr("href").replacingOccurrences(of: "book", with: "").replacingOccurrences(of: "/", with: "")
        }
        let coverUrl = try item.select("img.result-game-item-pic-link-img").first()?.attr("src") ?? ""
        let introduce = try item.select("p.result-game-item-desc").first()?.text() ?? ""
        var author: String = ""
        var category: String = ""
        var latestChapterTitle: String = ""
        var latestChapterTime: String = ""
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
            if children.count > 3 {
                latestChapterTime = try getText(element: children[2])
            }
            if children.count > 4 {
                latestChapterTitle = try getText(element: children[3])
            }
        }
        return SearchNovelInfo(id: id,
                               coverUrl: coverUrl,
                               title: title,
                               author: author,
                               category: category,
                               introduce: introduce,
                               latestChapterTitle: latestChapterTitle,
                               latestChapterTime: latestChapterTime)
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
