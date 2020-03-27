//
//  PrecureRepository.swift
//  Precure
//
//  Created by Hitoshi Abe on 2020/03/27.
//  Copyright © 2020 Hitoshi Abe. All rights reserved.
//

protocol PrecureRepository {

    var delegate: PrecureRepositoryDelegate? { get set }

    func sync() throws
    func precureCount() throws -> Int
    func precureSeriesCount() throws -> Int
    func fetchPrecureSeries() throws -> [PrecureSeries]
    func fetchPrecure(seriesId: PrecureSeries.ID?) throws -> [Precure]
    func allDelete() throws
}

protocol PrecureRepositoryDelegate: class {
    func didChangePrecure(_ precure: Precure, result: PrecureDidChangeResult)
}

enum PrecureDidChangeResult {
    case joined
    case grown
    case exited
}
