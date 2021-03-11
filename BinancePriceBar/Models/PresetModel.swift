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
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        coinPairs       <- map["coinPairs"]
    }
}
