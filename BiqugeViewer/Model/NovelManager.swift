//
//  NovelManager.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/22.
//

import Foundation

class NovelManager {
    
    @DefaultsProperty(key: "lastViewNovelId", defaultValue: nil)
    static var lastViewNovelId: String?
    
    @DefaultsProperty(key: "lastViewNovelLink", defaultValue: nil)
    static var lastViewNovelLink: String?
    
}
