//
//  NovelManager.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/22.
//

import Foundation
import CoreData

class NovelManager {
    
    @DefaultsProperty(key: "lastViewNovelId", defaultValue: nil)
    static var lastViewNovelId: String?
    
    @DefaultsProperty(key: "lastViewNovelLink", defaultValue: nil)
    static var lastViewNovelLink: String?
    
    struct NovelUserInfo {
        let isLiked: Bool
        let lastReadTitle: String?
        let lastReadLink: String?
    }
    
    struct BookrackNovelInfo {
        let id: String
        let title: String
        let author: String
        let coverUrl: String
    }
    
    static let shared: NovelManager = NovelManager()
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.flykite.BiqugeViewer.NovelManager", attributes: .concurrent)
    
    static func novelCoverUrl(novelId: String) -> String {
        guard novelId.count > 3 else { return "" }
        let endIndex = novelId.index(novelId.startIndex, offsetBy: novelId.count - 3)
        return "https://www.biquge.com.cn/files/article/image/\(String(novelId[..<endIndex]))/\(novelId)/\(novelId)s.jpg"
    }
    
    func setNovelLiked(novelId: String, isLiked: Bool, completion: ((Error?) -> Void)?) {
        updateNovel(novelId) { (entity) in
            entity.isLiked = isLiked
        } completion: { (error) in
            completion?(error)
        }
    }
    
    func setNovelLastRead(novelId: String, title: String, link: String, completion: ((Error?) -> Void)?) {
        updateNovel(novelId) { (entity) in
            entity.lastReadTitle = title
            entity.lastReadLink = link
        } completion: { (error) in
            completion?(error)
        }
    }
    
    func insertNovel(novel: NovelInfo, completion: ((Error?) -> Void)?) {
        guard let context = DBUtil.context else {
            completion?(NSError(domain: "Can not create context", code: -999, userInfo: nil))
            return
        }
        queue.async {
            var err: Error?
            do {
                if let entity = try self.queryNovelEntity(id: novel.id, in: context) {
                    entity.id = novel.id
                    entity.title = novel.title
                    entity.author = novel.author
                    entity.coverUrl = novel.coverUrl
                    if context.hasChanges {
                        try context.save()
                    }
                } else if let entity = NovelEntity.insertNewObject(into: context) {
                    entity.id = novel.id
                    entity.title = novel.title
                    entity.author = novel.author
                    entity.coverUrl = novel.coverUrl
                    try context.save()
                } else {
                    err = NSError(domain: "Unknown error", code: -999, userInfo: nil)
                }
            } catch {
                err = error
            }
            DispatchQueue.main.async {
                completion?(err)
            }
        }
    }
    
    func queryLikedNovels(completion: ((Result<[BookrackNovelInfo], Error>) -> Void)?) {
        guard let context = DBUtil.context else {
            completion?(.failure(NSError(domain: "Can not create context", code: -999, userInfo: nil)))
            return
        }
        queue.async {
            let result: Result<[BookrackNovelInfo], Error>
            do {
                let request: NSFetchRequest<NovelEntity> = NovelEntity.fetchRequest()
                request.predicate = NSPredicate(format: "isLiked = true")
                let records = try context.fetch(request)
                var novels: [BookrackNovelInfo] = []
                for record in records {
                    guard let id = record.id else { continue }
                    novels.append(BookrackNovelInfo(id: id,
                                                    title: record.title ?? "",
                                                    author: record.author ?? "",
                                                    coverUrl: record.coverUrl ?? ""))
                }
                result = .success(novels)
            } catch {
                result = .failure(error)
            }
            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }
    
    func queryNovelLikeAndLastRead(novelId: String, completion: ((Result<NovelUserInfo?, Error>) -> Void)?) {
        guard let context = DBUtil.context else {
            completion?(.failure(NSError(domain: "Can not create context", code: -999, userInfo: nil)))
            return
        }
        queue.async {
            let result: Result<NovelUserInfo?, Error>
            do {
                if let entity = try self.queryNovelEntity(id: novelId, in: context) {
                    let info = NovelUserInfo(isLiked: entity.isLiked,
                                             lastReadTitle: entity.lastReadTitle,
                                             lastReadLink: entity.lastReadLink)
                    result = .success(info)
                } else {
                    result = .success(nil)
                }
            } catch {
                result = .failure(error)
            }
            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }
    
    private func updateNovel(_ novelInfo: NovelInfo, updateAction: @escaping (NovelEntity) -> Void, completion: ((Error?) -> Void)?) {
        guard let context = DBUtil.context else {
            completion?(NSError(domain: "Can not create context", code: -999, userInfo: nil))
            return
        }
        queue.async {
            var err: Error?
            do {
                if let entity = try self.queryNovelEntity(id: novelInfo.id, in: context) {
                    updateAction(entity)
                    if context.hasChanges {
                        try context.save()
                    }
                } else if let entity = NovelEntity.insertNewObject(into: context) {
                    entity.id = novelInfo.id
                    entity.title = novelInfo.title
                    entity.author = novelInfo.author
                    entity.coverUrl = novelInfo.coverUrl
                    updateAction(entity)
                    try context.save()
                } else {
                    err = NSError(domain: "Unknown error", code: -999, userInfo: nil)
                }
            } catch {
                err = error
            }
            DispatchQueue.main.async {
                completion?(err)
            }
        }
    }
    
    private func updateNovel(_ novelId: String, updateAction: @escaping (NovelEntity) -> Void, completion: ((Error?) -> Void)?) {
        guard let context = DBUtil.context else {
            completion?(NSError(domain: "Can not create context", code: -999, userInfo: nil))
            return
        }
        queue.async {
            var err: Error?
            do {
                guard let entity = try self.queryNovelEntity(id: novelId, in: context) else {
                    throw NSError(domain: "Entity not found", code: -999, userInfo: ["novelId": novelId])
                }
                updateAction(entity)
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                err = error
            }
            DispatchQueue.main.async {
                completion?(err)
            }
        }
    }
    
    private func queryNovelEntity(id: String, in context: NSManagedObjectContext) throws -> NovelEntity? {
        let request: NSFetchRequest<NovelEntity> = NovelEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        let records = try context.fetch(request)
        return records.first
    }
    
}
