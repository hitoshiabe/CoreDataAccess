//
//  CoreDataAccessable.swift
//  CoreDataAccess
//
//  Created by Hitoshi Abe on 2020/03/27.
//  Copyright © 2020 Hitoshi Abe. All rights reserved.
//

import CoreData

public protocol CoreDataAccessable {

    var mainContext: NSManagedObjectContext { get }
    func createBackgroundContext() -> NSManagedObjectContext

    init(modelName: String, storeURL: URL)

    func save(in context: NSManagedObjectContext) throws
}

public extension CoreDataAccessable {

    init(modelName: String, dbFileName: String) {
        guard
            let storeURL = try? FileManager
                .default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(dbFileName) else {
            fatalError()
        }
        self.init(modelName: modelName, storeURL: storeURL)
    }
}

public extension CoreDataAccessable {

    func insert<T>(type: T.Type, in context: NSManagedObjectContext) -> T where T : NSManagedObject {
        guard let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: type), into: context) as? T else { fatalError() }
        return object
    }

    func fetch<T>(type: T.Type, in context: NSManagedObjectContext, request: NSFetchRequest<T>) throws -> [T] where T : NSManagedObject {
        return try context.fetch(request)
    }

    func count<T>(type: T.Type, in context: NSManagedObjectContext, request: NSFetchRequest<T>) throws -> Int where T : NSManagedObject {
        return try context.count(for: request)
    }

    func delete<T>(type: T.Type, in context: NSManagedObjectContext, request: NSFetchRequest<T>) throws where T : NSManagedObject {
        let objects: [T] = try fetch(type: type, in: context, request: request)
        objects.forEach { context.delete($0) }
    }
}

public extension CoreDataAccessable {

    func upsert<T>(type: T.Type, in context: NSManagedObjectContext, request: NSFetchRequest<T>) -> T where T: NSManagedObject {
        return fetch(type: type, in: context, request: request) ?? insert(type: type, in: context)
    }

    func fetch<T>(type: T.Type, in context: NSManagedObjectContext, request: NSFetchRequest<T>) -> T? where T: NSManagedObject {
        let req = request
        req.fetchLimit = 1
        guard
            let objects: [T] = try? fetch(type: type, in: context, request: req),
            let object = objects.first else {
                return nil
        }
        return object
    }
}

public extension CoreDataAccessable {

    func upsert<T>(type: T.Type, in context: NSManagedObjectContext, predicate: NSPredicate? = nil) -> T where T: NSManagedObject {
        let request = self.request(type: type, predicate: predicate, sortDescriptors: nil, fetchLimit: nil)
        return fetch(type: type, in: context, request: request) ?? insert(type: type, in: context)
    }

    func fetch<T>(type: T.Type, in context: NSManagedObjectContext, predicate: NSPredicate?) -> T? where T: NSManagedObject {
        let request = self.request(type: type, predicate: predicate, sortDescriptors: nil, fetchLimit: nil)
        return fetch(type: type, in: context, request: request)
    }

    func fetch<T>(type: T.Type, in context: NSManagedObjectContext, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil) throws -> [T] where T: NSManagedObject {
        let request = self.request(type: type, predicate: predicate, sortDescriptors: sortDescriptors, fetchLimit: fetchLimit)
        let objects: [T] = try fetch(type: type, in: context, request: request)
        return objects
    }

    func count<T>(type: T.Type, in context: NSManagedObjectContext, predicate: NSPredicate? = nil) throws -> Int where T: NSManagedObject {
        let request = self.request(type: type, predicate: predicate, sortDescriptors: nil, fetchLimit: nil)
        return try count(type: type, in: context, request: request)
    }

    func delete<T>(type: T.Type, in context: NSManagedObjectContext, predicate: NSPredicate? = nil) throws where T: NSManagedObject {
        let request = self.request(type: type, predicate: predicate, sortDescriptors: nil, fetchLimit: nil)
        try delete(type: type, in: context, request: request)
    }
}

public extension CoreDataAccessable {

    func fetch<T>(type: T.Type, predicate: NSPredicate?) -> T? where T: NSManagedObject {
        return fetch(type: type, in: mainContext, predicate: predicate)
    }

    func fetch<T>(type: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil) throws -> [T] where T: NSManagedObject {
        return try fetch(type: type, in: mainContext, predicate: predicate, sortDescriptors: sortDescriptors, fetchLimit: fetchLimit)
    }

    func count<T>(type: T.Type, predicate: NSPredicate? = nil) throws -> Int where T: NSManagedObject {
        return try count(type: type, in: mainContext, predicate: predicate)
    }

    func save() throws {
        try save(in: mainContext)
    }
}

public extension CoreDataAccessable {

    func save(in context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        var saveError: Error?
        context.performAndWait {
            do {
                try context.save()
            } catch {
                saveError = error
            }
        }
        if let error = saveError {
            throw error
        }
    }
}

public extension CoreDataAccessable {

    func createFetchResultsController<T>(type: T.Type, in context: NSManagedObjectContext, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, fetchLimit: Int? = nil, sectionNameKeyPath: String? = nil, cacheName name: String? = nil, delegate: NSFetchedResultsControllerDelegate? = nil) -> NSFetchedResultsController<T> where T: NSManagedObject {
        let request = self.request(type: type, predicate: predicate, sortDescriptors: sortDescriptors, fetchLimit: fetchLimit)
        return createFetchResultsController(type: type, in: context, request: request, sectionNameKeyPath: sectionNameKeyPath, cacheName: name, delegate: delegate)
    }

    func createFetchResultsController<T>(type: T.Type, in context: NSManagedObjectContext, request: NSFetchRequest<T>, sectionNameKeyPath: String? = nil, cacheName name: String? = nil, delegate: NSFetchedResultsControllerDelegate? = nil) -> NSFetchedResultsController<T> where T: NSManagedObject {
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: name)
        controller.delegate = delegate
        context.performAndWait {
            try? controller.performFetch()
        }
        return controller
    }
}

private extension CoreDataAccessable {

    func request<T>(type: T.Type, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, fetchLimit: Int?) -> NSFetchRequest<T> where T: NSManagedObject {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        if let fetchLimit = fetchLimit {
            request.fetchLimit = fetchLimit
        }
        return request
    }
}
