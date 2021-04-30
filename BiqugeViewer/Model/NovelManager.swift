//
//  BookManager.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/22.
//

import Foundation
import CoreData

class BookManager {
    
    @DefaultsProperty(key: "lastViewNovelId", defaultValue: nil)
    static var lastViewBookId: String?
    
    @DefaultsProperty(key: "lastViewNovelLink", defaultValue: nil)
    static var lastViewBookLink: String?
    
    struct BookUserInfo {
        let isLiked: Bool
        let lastReadTitle: String?
        let lastReadLink: String?
    }
    
    struct BookrackBookInfo {
        let id: String
        let title: String
        let author: String
    }
    
    static let shared: BookManager = BookManager()
    
    private let queue: DispatchQueue = DispatchQueue(label: "com.flykite.BiqugeViewer.BookManager", attributes: .concurrent)
    
    func setBookLiked(bookId: String, isLiked: Bool, completion: ((Error?) -> Void)?) {
        updateBook(bookId) { (entity) in
            entity.isLiked = isLiked
        } completion: { (error) in
            completion?(error)
        }
    }
    
    func setBookLastRead(bookId: String, title: String, link: String, completion: ((Error?) -> Void)?) {
        updateBook(bookId) { (entity) in
            entity.lastReadTitle = title
            entity.lastReadLink = link
        } completion: { (error) in
            completion?(error)
        }
    }
    
    func insertBook(book: BookInfo, completion: ((Error?) -> Void)?) {
        guard let context = DBUtil.context else {
            completion?(NSError(domain: "Can not create context", code: -999, userInfo: nil))
            return
        }
        queue.async {
            var err: Error?
            do {
                if let entity = try self.queryBookEntity(id: book.id, in: context) {
                    entity.id = book.id
                    entity.title = book.title
                    entity.author = book.author
                    if context.hasChanges {
                        try context.save()
                    }
                } else if let entity = BookEntity.insertNewObject(into: context) {
                    entity.id = book.id
                    entity.title = book.title
                    entity.author = book.author
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
    
    func queryLikedBooks(completion: ((Result<[BookrackBookInfo], Error>) -> Void)?) {
        guard let context = DBUtil.context else {
            completion?(.failure(NSError(domain: "Can not create context", code: -999, userInfo: nil)))
            return
        }
        queue.async {
            let result: Result<[BookrackBookInfo], Error>
            do {
                let request: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
                request.predicate = NSPredicate(format: "isLiked = true")
                let records = try context.fetch(request)
                var books: [BookrackBookInfo] = []
                for record in records {
                    guard let id = record.id else { continue }
                    books.append(BookrackBookInfo(id: id,
                                                  title: record.title ?? "",
                                                  author: record.author ?? ""))
                }
                result = .success(books)
            } catch {
                result = .failure(error)
            }
            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }
    
    func queryBookLikeAndLastRead(bookId: String, completion: ((Result<BookUserInfo?, Error>) -> Void)?) {
        guard let context = DBUtil.context else {
            completion?(.failure(NSError(domain: "Can not create context", code: -999, userInfo: nil)))
            return
        }
        queue.async {
            let result: Result<BookUserInfo?, Error>
            do {
                if let entity = try self.queryBookEntity(id: bookId, in: context) {
                    let info = BookUserInfo(isLiked: entity.isLiked,
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
    
    private func updateBook(_ bookInfo: BookInfo, updateAction: @escaping (BookEntity) -> Void, completion: ((Error?) -> Void)?) {
        guard let context = DBUtil.context else {
            completion?(NSError(domain: "Can not create context", code: -999, userInfo: nil))
            return
        }
        queue.async {
            var err: Error?
            do {
                if let entity = try self.queryBookEntity(id: bookInfo.id, in: context) {
                    updateAction(entity)
                    if context.hasChanges {
                        try context.save()
                    }
                } else if let entity = BookEntity.insertNewObject(into: context) {
                    entity.id = bookInfo.id
                    entity.title = bookInfo.title
                    entity.author = bookInfo.author
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
    
    private func updateBook(_ bookId: String, updateAction: @escaping (BookEntity) -> Void, completion: ((Error?) -> Void)?) {
        guard let context = DBUtil.context else {
            completion?(NSError(domain: "Can not create context", code: -999, userInfo: nil))
            return
        }
        queue.async {
            var err: Error?
            do {
                guard let entity = try self.queryBookEntity(id: bookId, in: context) else {
                    throw NSError(domain: "Entity not found", code: -999, userInfo: ["bookId": bookId])
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
    
    private func queryBookEntity(id: String, in context: NSManagedObjectContext) throws -> BookEntity? {
        let request: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        let records = try context.fetch(request)
        return records.first
    }
    
}
