//
//  Novel.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/20.
//

import Foundation
import SwiftSoup

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
