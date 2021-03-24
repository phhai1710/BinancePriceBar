//
//  PresetModel.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/7/21.
//

import Foundation
import ObjectMapper

class PresetModel: Mappable {
    var coinPairs: [CoinPairModel] = []
    var chartInterval: ChartInterval = .h1
    var fontSize: Int?
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        coinPairs       <- map["coinPairs"]
        let transform = TransformOf<ChartInterval, String>(fromJSON: { (value: String?) -> ChartInterval? in
            if let value = value {
                return ChartInterval(rawValue: value)
            }
            return nil
        }, toJSON: { (value: ChartInterval?) -> String? in
            return value?.rawValue
        })
        chartInterval   <- (map["chartInterval"], transform)
        fontSize        <- map["fontSize"]
    }
}

extension PresetModel {
    enum ChartInterval: String, CaseIterable {
        case m1 = "1m"
        case m5 = "5m"
        case m15 = "15m"
        case m30 = "30m"
        case h1 = "1h"
        case h2 = "2h"
        case h4 = "4h"
        case h6 = "6h"
        case h12 = "12h"
        case d1 = "1d"
        case d3 = "3d"
        case w1 = "1w"
        case M1 = "1M"
    }
}
