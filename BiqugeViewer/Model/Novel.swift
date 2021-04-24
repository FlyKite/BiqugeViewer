//
//  Novel.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/20.
//

import Foundation
import SwiftSoup

struct HomeRecommend {
    let category: String
    let mainNovel: RecommendNovel?
    let novels: [RecommendNovel]
    
    struct RecommendNovel {
        let id: String
        let title: String
        let author: String
        let introduce: String?
    }
    
    static func handle(from html: String) throws -> [HomeRecommend] {
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
    
    private static func getTitle(element: Element) throws -> String {
        return try element.select("h2.title").select("span").first()?.text() ?? ""
    }
    
    private static func getMainNovel(element: Element) throws -> RecommendNovel? {
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
        return RecommendNovel(id: id, title: title ?? "", author: author ?? "", introduce: introduce ?? "")
    }
    
    private static func getNovels(element: Element) throws -> [RecommendNovel] {
        guard let list = try element.select("ul").first()?.select("li") else { return [] }
        var results: [RecommendNovel] = []
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
                results.append(RecommendNovel(id: id, title: title, author: author, introduce: nil))
            }
        }
        return results
    }
}

struct NovelInfo {
    let id: String
    let title: String
    let author: String
    let state: String
    let introduce: String
    let coverUrl: String
    let pageNameList: [String]
    
    let chapters: [NovelChapter]
    
    static func handle(from html: String, novelId: String) throws -> NovelInfo {
        let doc = try SwiftSoup.parse(html)
        let title = try getTitle(document: doc)
        let (author, state) = try getAuthorAndState(document: doc)
        let introduce = try getIntroduce(document: doc)
        let cover = try getCoverUrl(document: doc)
        let pages = try getPageList(document: doc)
        let chapters = try NovelChapter.handle(from: doc)
        return NovelInfo(id: novelId,
                         title: title,
                         author: author,
                         state: state,
                         introduce: introduce,
                         coverUrl: cover,
                         pageNameList: pages,
                         chapters: chapters)
    }
    
    private static func getTitle(document: Document) throws -> String {
        return try document.getElementById("bqgmb_h1")?.text() ?? ""
    }
    
    private static func getAuthorAndState(document: Document) throws -> (String, String) {
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
    
    private static func getIntroduce(document: Document) throws -> String {
        return try document.select("div.intro_info").first()?.text() ?? ""
    }
    
    private static func getCoverUrl(document: Document) throws -> String {
        return try document.select("div.block_img2").select("img").first()?.attr("src") ?? ""
    }
    
    private static func getPageList(document: Document) throws -> [String] {
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

struct NovelChapter {
    let title: String
    let link: String
    
    static func handle(from html: String) throws -> [NovelChapter] {
        let doc = try SwiftSoup.parse(html)
        return try handle(from: doc)
    }
    
    static func handle(from doc: Document) throws -> [NovelChapter] {
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

struct Novel {
    let link: String
    let html: String
    let title: String
    let content: String
    
    let nextChapterLink: String?
    
    static func handle(from html: String, link: String) throws -> Novel {
        let doc = try SwiftSoup.parse(html)
        let title = try getTitle(document: doc)
        let nextChapterLink = try getNextChapterLink(document: doc)
        let content = try getContent(document: doc)
        return Novel(link: link, html: html, title: title, content: content, nextChapterLink: nextChapterLink)
    }
    
    private static func getTitle(document: Document) throws -> String {
        return try document.getElementById("nr_title")?.text() ?? ""
    }
    
    private static func getNextChapterLink(document: Document) throws -> String? {
        guard let element = try document.select("td.next_chapter").select("a.jump-chapter-links").first() else {
            return nil
        }
        return try element.attr("href")
    }
    
    private static func getContent(document: Document) throws -> String {
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
