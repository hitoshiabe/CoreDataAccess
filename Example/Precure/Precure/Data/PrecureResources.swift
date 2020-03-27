//
//  PrecureResources.swift
//  Precure
//
//  Created by Hitoshi Abe on 2020/03/27.
//  Copyright © 2020 Hitoshi Abe. All rights reserved.
//

struct PrecureResources {

    let precureList: [PrecureResponse] = [
        .init(name: "美墨なぎさ", precureName: "キュアブラック", cv: "本名陽子", color: .black, seriesId: 1, isHeroine: true),
        .init(name: "雪城ほのか", precureName: "キュアホワイト", cv: "ゆかな", color: .white, seriesId: 1, isHeroine: false)
    ]

    let precureSeriesList: [PrecureSeriesResponse] = [
        .init(seriesId: 1, title: "ふたりはプリキュア", startYear: 2004),
        .init(seriesId: 2, title: "ふたりはプリキュア Max Heart", startYear: 2005),
        .init(seriesId: 3, title: "ふたりはプリキュア Splash Star", startYear: 2006),
        .init(seriesId: 4, title: "Yes!プリキュア5", startYear: 2007),
        .init(seriesId: 5, title: "Yes!プリキュア5GoGo!", startYear: 2008),
        .init(seriesId: 6, title: "フレッシュプリキュア!", startYear: 2009),
        .init(seriesId: 7, title: "ハートキャッチプリキュア!", startYear: 2010),
        .init(seriesId: 8, title: "スイートプリキュア♪", startYear: 2011),
        .init(seriesId: 9, title: "スマイルプリキュア!", startYear: 2012),
        .init(seriesId: 10, title: "ドキドキ!プリキュア", startYear: 2013),
        .init(seriesId: 11, title: "ハピネスチャージプリキュア!", startYear: 2014),
        .init(seriesId: 12, title: "Go!プリンセスプリキュア", startYear: 2015),
        .init(seriesId: 13, title: "魔法つかいプリキュア!", startYear: 2016),
        .init(seriesId: 14, title: "キラキラ☆プリキュアアラモード", startYear: 2017),
        .init(seriesId: 15, title: "HUGっと!プリキュア", startYear: 2018),
        .init(seriesId: 16, title: "スター☆トゥインクルプリキュア", startYear: 2019),
        .init(seriesId: 17, title: "ヒーリングっど♥プリキュア", startYear: 2020)
    ]
}

typealias PrecureResponse = Precure
typealias PrecureSeriesResponse = PrecureSeries

private extension PrecureResponse {
    init(name: String, precureName: String, cv: String, color: PrecureResponse.Color, seriesId: Int16, isHeroine: Bool) {
        self.name = name
        self.precureName = precureName
        self.cv = cv
        self.color = color
        self.seriesId = .init(value: seriesId)
        self.isHeroine = isHeroine
    }
}

private extension PrecureSeriesResponse {
    init(seriesId: Int16, title: String, startYear: Int16) {
        self.seriesId = .init(value: seriesId)
        self.title = title
        self.startYear = Int(startYear)
    }
}
