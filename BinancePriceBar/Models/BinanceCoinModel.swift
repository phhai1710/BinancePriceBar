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
    var price: Double?
    var pricePercentChange: Double?
    var vol24h: Double?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        stream                  <- map["stream"]
        pair                    <- map["data.s"]
        
        let transform = TransformOf<Double, String>(fromJSON: { (value: String?) -> Double? in
            if let value = value {
                return Double(value)
            }
            return nil
        }, toJSON: { (value: Double?) -> String? in
            if let value = value {
                return String(value)
            }
            return nil
        })
        
        price                   <- (map["data.c"], transform)
        pricePercentChange      <- (map["data.P"], transform)
        vol24h                  <- (map["data.q"], transform)
    }
}
