//
//  CoinPair.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/7/21.
//

import ObjectMapper

class CoinPairModel: Mappable, Hashable {
    
    var pair: String = ""
    var name: String = ""
    var icon: String = ""
    var iconData: String = ""
    var colorHex: String = ""
    var aboveAlertPrice: Double?
    var belowAlertPrice: Double?

    required init?(map: Map) {
        
    }
    
    init(pair: String, colorHex: String) {
        self.pair = pair
        self.colorHex = colorHex
    }
    
    func mapping(map: Map) {
        pair                    <- map["pair"]
        name                    <- map["name"]
        icon                    <- map["icon"]
        iconData                <- map["iconData"]
        colorHex                <- map["colorHex"]
        aboveAlertPrice         <- map["aboveAlertPrice"]
        belowAlertPrice         <- map["belowAlertPrice"]
    }
    
    static func == (lhs: CoinPairModel, rhs: CoinPairModel) -> Bool {
        return lhs.pair == rhs.pair
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(pair)
    }
}
