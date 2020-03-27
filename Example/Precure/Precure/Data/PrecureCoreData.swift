//
//  PrecureCoreData.swift
//  Precure
//
//  Created by Hitoshi Abe on 2020/03/27.
//  Copyright © 2020 Hitoshi Abe. All rights reserved.
//

import CoreDataAccess

final class PrecureCoreData: /*CoreData*/ SaferCoreData {

    static let shared = PrecureCoreData(modelName: PrecureCoreData.modelName,
                                        dbFileName: PrecureCoreData.dbFileName)

    static let modelName = "Precure"
    static let dbFileName = "\(PrecureCoreData.modelName).sqlite"
}
