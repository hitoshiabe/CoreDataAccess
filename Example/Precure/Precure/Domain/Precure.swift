//
//  Precure.swift
//  Precure
//
//  Created by Hitoshi Abe on 2020/03/27.
//  Copyright © 2020 Hitoshi Abe. All rights reserved.
//

struct Precure {
    let name: String
    let precureName: String
    let cv: String
    let color: Color
    let seriesId: PrecureSeries.ID
    let isHeroine: Bool

    enum Color: Int16 {
        case black
        case white
    }
}

struct PrecureSeries {
    let seriesId: ID
    let title: String
    let startYear: Int

    struct ID: Hashable {
        let value: Int16
    }
}
