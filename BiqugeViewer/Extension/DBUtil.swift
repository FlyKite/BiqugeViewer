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
    
    private static func getContext() -> NSManagedObjectContext? {
        var url = URL(fileURLWithPath: NSHomeDirectory())
        url.appendPathComponent("Documents")
        url.appendPathComponent("Novel.sqlite")
        
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
}

extension NSManagedObject {
    static func insertNewObject(into context: NSManagedObjectContext) -> Self? {
        return NSEntityDescription.insertNewObject(forEntityName: "\(self)", into: context) as? Self
    }
}
