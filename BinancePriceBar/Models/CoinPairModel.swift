//
//  CoinPair.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/7/21.
//

import ObjectMapper

class CoinPairModel: Mappable, Hashable {
    
    var pair: String = ""
    var icon: String = ""
    var iconData: String = ""
    var colorHex: String = ""

    required init?(map: Map) {
        
    }
    
    init(pair: String, colorHex: String) {
        self.pair = pair
        self.colorHex = colorHex
    }
    
    func mapping(map: Map) {
        pair            <- map["pair"]
        icon            <- map["icon"]
        iconData        <- map["iconData"]
        colorHex        <- map["colorHex"]
    }
    
    static func == (lhs: CoinPairModel, rhs: CoinPairModel) -> Bool {
        return lhs.pair == rhs.pair
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(pair)
    }
}
