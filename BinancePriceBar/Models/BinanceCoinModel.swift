//
//  BinanceCoinModel.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 2/28/21.
//

import Foundation
import ObjectMapper

class BinanceCoinModel: Mappable {
    var pair: String?
    var stream: String?
    var price: String?
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        stream      <- map["stream"]
        pair          <- map["data.s"]
        price       <- map["data.c"]
    }
    
    
}
