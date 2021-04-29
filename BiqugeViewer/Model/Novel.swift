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
}

struct SearchNovelInfo {
    let id: String
    let coverUrl: String
    let title: String
    let author: String
    let category: String
    let introduce: String
    let latestChapterTitle: String
    let latestChapterTime: String
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
}

struct NovelChapter {
    let title: String
    let link: String
}

struct Novel {
    let link: String
    let html: String
    let title: String
    let content: String
    
    let nextChapterLink: String?
}
