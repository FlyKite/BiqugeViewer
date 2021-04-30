//
//  Book.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/20.
//

import Foundation
import SwiftSoup

struct HomeRecommend {
    let category: String
    let mainBook: BookInfo?
    let books: [BookInfo]
    
    struct BookInfo {
        let id: String
        let title: String
        let author: String
        let introduce: String?
    }
}

struct BookInfo {
    let id: String
    let title: String
    let author: String
    let category: String
    let introduce: String
    let pageNameList: [String]
    
    let chapters: [ChapterItem]
    
    struct ChapterItem {
        let title: String
        let link: String
    }
    
    init(id: String, title: String, author: String, category: String, introduce: String, pageNameList: [String] = [], chapters: [ChapterItem] = []) {
        self.id = id
        self.title = title
        self.author = author
        self.category = category
        self.introduce = introduce
        self.pageNameList = pageNameList
        self.chapters = chapters
    }
}

struct BookChapter {
    let link: String
    let html: String
    let title: String
    let content: String
    
    let nextChapterLink: String?
}
