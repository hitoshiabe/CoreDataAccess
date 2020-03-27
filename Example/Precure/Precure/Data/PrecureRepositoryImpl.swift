//
//  PrecureRepositoryImpl.swift
//  Precure
//
//  Created by Hitoshi Abe on 2020/03/27.
//  Copyright © 2020 Hitoshi Abe. All rights reserved.
//

import CoreDataAccess

final class PrecureRepositoryImpl {

    weak var delegate: PrecureRepositoryDelegate?

    private let coreData: CoreDataAccessable
    init(coreData: CoreDataAccessable = PrecureCoreData.shared) {
        self.coreData = coreData

        observer.start()
    }

    deinit {
        observer.stop()
    }

    private lazy var observer: ManagedObjectObserver = {
        return ManagedObjectObserver(delegate: self, context: coreData.mainContext)
    }()

    private lazy var resources: PrecureResources = {
        return PrecureResources()
    }()
}

extension PrecureRepositoryImpl: PrecureRepository {

    func sync() throws {
        let context = coreData.createBackgroundContext()
        context.performAndWait {
            for precure in resources.precureList {
                let precurePredicate = NSPredicate(format: "name == %@", precure.name)
                let precureEntity = coreData.upsert(type: PrecureEntity.self, in: context, predicate: precurePredicate)
                precureEntity.name = precure.name
                precureEntity.precure_name = precure.precureName
                precureEntity.cv = precure.cv
                precureEntity.color = precure.color.rawValue
                precureEntity.heroine = precure.isHeroine

                let series = resources.precureSeriesList.first { (precureSeries) -> Bool in
                    return precureSeries.seriesId == precure.seriesId
                }
                if let series = series {
                    let precureSeriesPredicate = NSPredicate(format: "series_id == %@", NSNumber(value: series.seriesId.value))
                    let seriesEntity = coreData.upsert(type: PrecureSeriesEntity.self, in: context, predicate: precureSeriesPredicate)
                    seriesEntity.series_id = series.seriesId.value
                    seriesEntity.title = series.title
                    seriesEntity.start_year = Int16(series.startYear)

                    seriesEntity.precures?.adding(precureEntity)
                    precureEntity.series = seriesEntity
                }
            }
        }
        try coreData.save(in: context)
    }

    func precureCount() throws -> Int {
        return try coreData.count(type: PrecureEntity.self, in: coreData.mainContext, predicate: nil)
    }

    func precureSeriesCount() throws -> Int {
        return try coreData.count(type: PrecureSeriesEntity.self, in: coreData.mainContext, predicate: nil)
    }

    func fetchPrecureSeries() throws -> [PrecureSeries] {
        let result = try coreData.fetch(type: PrecureSeriesEntity.self, predicate: nil, fetchLimit: nil)
        return result.compactMap { $0.convert() }
    }

    func fetchPrecure(seriesId: PrecureSeries.ID?) throws -> [Precure] {
        var predicate: NSPredicate?
        if let seriesId = seriesId {
            predicate = NSPredicate(format: "series_id == %@", NSNumber(value: seriesId.value))
        }
        let result = try coreData.fetch(type: PrecureEntity.self, predicate: predicate, fetchLimit: nil)
        return result.compactMap { $0.convert() }
    }

    func allDelete() throws {
        let all = [
            PrecureEntity.self,
            PrecureSeriesEntity.self
        ]
        try all.forEach { try coreData.delete(type: $0, in: coreData.mainContext, predicate: nil) }
    }
}

extension PrecureRepositoryImpl: ManagedObjectObserverDelegate {

    func didChangeManagedObject(_ object: ManagedObject, result: ManagedObjectDidChangeResult) {
        if let precureEntity = object as? PrecureEntity, let precure = precureEntity.convert() {
            delegate?.didChangePrecure(precure, result: result.precureResult)
        }
    }
}

private extension PrecureEntity {
    func convert() -> Precure? {
        guard
            let name = self.name,
            let precureName = self.precure_name,
            let cv = self.cv,
            let color = Precure.Color(rawValue: self.color) else {
            return nil
        }
        return .init(name: name, precureName: precureName, cv: cv, color: color, seriesId: .init(value: self.series_id), isHeroine: self.heroine)
    }
}

private extension PrecureSeriesEntity {
    func convert() -> PrecureSeries? {
        guard let title = self.title else { return nil }
        return .init(seriesId: .init(value: self.series_id), title: title, startYear: Int(self.start_year))
    }
}

private extension ManagedObjectDidChangeResult {
    var precureResult: PrecureDidChangeResult {
        switch self {
        case .inserted: return .joined
        case .updated: return .grown
        case .deleted: return .exited
        }
    }
}
