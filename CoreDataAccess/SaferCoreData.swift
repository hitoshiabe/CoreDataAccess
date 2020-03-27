//
//  SaferCoreData.swift
//  CoreDataAccess
//
//  Created by Hitoshi Abe on 2020/03/27.
//  Copyright © 2020 Hitoshi Abe. All rights reserved.
//

import CoreData

open class SaferCoreData: CoreDataAccessable {

    private let writeContext: NSManagedObjectContext

    open lazy var mainContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.automaticallyMergesChangesFromParent = true
        context.parent = writeContext
        return context
    }()

    open func createBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.automaticallyMergesChangesFromParent = true
        context.parent = mainContext
        return context
    }

    public required init(modelName: String, storeURL: URL) {
        guard
            let schemeUrl = Bundle.main.url(forResource: modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: schemeUrl) else {
                fatalError()
        }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true])
        } catch {
            fatalError()
        }
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        context.automaticallyMergesChangesFromParent = true
        writeContext = context
    }
}
