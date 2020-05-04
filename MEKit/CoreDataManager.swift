//
//  CoreDataManager.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 12/01/2020.
//  Copyright © 2020 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation
import CoreData

public final class CoreDataManager {
    private(set) static var containerName: String!
    private(set) static var modelName: String? // "Model.momd/Model.mom"
    private(set) static var inMemoryContainer: Bool!
    private static var persistentContainer: NSPersistentContainer!
    
    public static var model: NSManagedObjectModel {
        return Self.persistentContainer.managedObjectModel
    }

    public static func configure(containerName: String, modelName: String? = nil, inMemoryContainer: Bool = false) {
        self.containerName = containerName
        self.modelName = modelName
        self.inMemoryContainer = inMemoryContainer
   
        var container: NSPersistentContainer!
        
        if let modelName = modelName {
            let modelURL = Bundle.main.url(forResource: modelName, withExtension: nil)!
            let model = NSManagedObjectModel(contentsOf: modelURL)!
            container = NSPersistentContainer(name: containerName, managedObjectModel: model)
        } else {
            container = NSPersistentContainer(name: containerName)
        }
        
        if inMemoryContainer {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                Self.processError(error)
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        self.persistentContainer = container
    }
    
    public static var viewContex: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public static func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    public static func performAndWaitBackgroundTask(_ block: (NSManagedObjectContext) -> Void) {
        let context = newBackgroundContext()
        context.performAndWait {
            block(context)
        }
    }
    
    public static func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    public static func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                Self.processError(error)
            }
        }
    }
    
    // MARK: - Creation
 
    public static func createTemporary<T: NSManagedObject>(_ type: T.Type) -> T {
        return NSManagedObject(entity: type.entityDescription(model: Self.persistentContainer.managedObjectModel), insertInto: nil) as! T
    }
      
    // MARK: - delete
    
    public static func batchDelete<T: NSManagedObject>(_ type: T.Type, where predicate: NSPredicate? = nil, in context: NSManagedObjectContext) {
        let fetchRequest = type.fetchRequest(resultOf: NSFetchRequestResult.self, where: predicate)
        let deleteFetchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteFetchRequest.resultType = .resultTypeObjectIDs
        
        do {
            let result = try persistentContainer.persistentStoreCoordinator.execute(deleteFetchRequest, with: context) as? NSBatchDeleteResult
            
            if viewContex !== context {
                guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [viewContex])
            }
        } catch {
            fatalError("Failed to execute request: \(error)")
        }
    }
    
    static public func deleteAll() {
        persistentContainer.persistentStoreDescriptions.forEach { description in
            if let url = description.url {
                try? persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
            }
        }
    }
    
    fileprivate static func processError(_ error: Error) {
        let nserror = error as NSError
        assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
    }
    
}

