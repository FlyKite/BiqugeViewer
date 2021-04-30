//
//  DBUtil.swift
//  BiqugeViewer
//
//  Created by FlyKite on 2021/4/24.
//

import Foundation
import CoreData

class DBUtil {
    
    static let context: NSManagedObjectContext? = getContext()
    
    private static let documentsUrl: URL = {
        var url = URL(fileURLWithPath: NSHomeDirectory())
        url.appendPathComponent("Documents")
        return url
    }()
    
    private static func getContext() -> NSManagedObjectContext? {
        renameToBook()
        
        let url = documentsUrl.appendingPathComponent("Book.sqlite")
        
        guard let modelUrl = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
            return nil
        }
        guard let model = NSManagedObjectModel(contentsOf: modelUrl) else {
            return nil
        }
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            print(error)
            return nil
        }
        
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }
    
    private static func renameToBook() {
        var url = documentsUrl.appendingPathComponent("Novel.sqlite")
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.moveItem(at: url, to: documentsUrl.appendingPathComponent("Book.sqlite"))
        }
        url = documentsUrl.appendingPathComponent("Novel.sqlite-shm")
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.moveItem(at: url, to: documentsUrl.appendingPathComponent("Book.sqlite-shm"))
        }
        url = documentsUrl.appendingPathComponent("Novel.sqlite-wal")
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.moveItem(at: url, to: documentsUrl.appendingPathComponent("Book.sqlite-wal"))
        }
    }
}

extension NSManagedObject {
    static func insertNewObject(into context: NSManagedObjectContext) -> Self? {
        return NSEntityDescription.insertNewObject(forEntityName: "\(self)", into: context) as? Self
    }
}
