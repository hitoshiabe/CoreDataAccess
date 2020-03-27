//
//  ManagedObjectObserver.swift
//  CoreDataAccess
//
//  Created by Hitoshi Abe on 2020/03/27.
//  Copyright © 2020 Hitoshi Abe. All rights reserved.
//

import CoreData

open class ManagedObjectObserver {
    private weak var delegate: ManagedObjectObserverDelegate?
    private let context: NSManagedObjectContext
    private var token: NSObjectProtocol?
    public init(delegate: ManagedObjectObserverDelegate?, context: NSManagedObjectContext) {
        self.delegate = delegate
        self.context = context
    }

    open func start() {
        stop()
        token = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: context, queue: .main) { [weak self] (notification) in
            guard let self = self, let userInfo = notification.userInfo else { return }

            let priority: [ManagedObjectDidChangeResult] = [.inserted, .deleted, .updated]
            for result in priority {
                guard let objects = userInfo[result.key] as? Set<NSManagedObject>, !objects.isEmpty else { continue }
                objects.forEach { self.delegate?.didChangeManagedObject($0, result: result) }
            }
        }
    }

    open func stop() {
        token.map { NotificationCenter.default.removeObserver($0) }
        token = nil
    }
}

public protocol ManagedObjectObserverDelegate: class {
    func didChangeManagedObject(_ object: NSManagedObject, result: ManagedObjectDidChangeResult)
}

public enum ManagedObjectDidChangeResult {
    case inserted
    case updated
    case deleted
}

private extension ManagedObjectDidChangeResult {
    var key: String {
        switch self {
        case .inserted: return NSInsertedObjectsKey
        case .updated: return NSUpdatedObjectsKey
        case .deleted: return NSDeletedObjectsKey
        }
    }
}
