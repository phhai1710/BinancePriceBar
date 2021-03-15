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
    }
}

extension PresetModel {
    enum ChartInterval: String {
        case m1, m5, m15, m30, h1, h2, h4, h6, h12, d1, d3, w1, M1
        
        func intervalValue() -> String {
            switch self {
            case .m1:
                return "1m"
            case .m5:
                return "5m"
            case .m15:
                return "15m"
            case .m30:
                return "30m"
            case .h1:
                return "1h"
            case .h2:
                return "2h"
            case .h4:
                return "4h"
            case .h6:
                return "6h"
            case .h12:
                return "12h"
            case .d1:
                return "1d"
            case .d3:
                return "3d"
            case .w1:
                return "1w"
            case .M1:
                return "1M"
            }
        }
    }
}
