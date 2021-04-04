//
//  KLineChartModel.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/28/21.
//

import Foundation

final class KLineChartModel {
    var openTime: Int64
    var openPrice: Double
    var highPrice: Double
    var lowPrice: Double
    var closePrice: Double
    var volume: Double
    
    init?(object: [Any]) {
        if let openTime = object.get(0) as? Int64,
           let openPrice = (object.get(1) as? String)?.toDouble(),
           let highPrice = (object.get(2) as? String)?.toDouble(),
           let lowPrice = (object.get(3) as? String)?.toDouble(),
           let closePrice = (object.get(4) as? String)?.toDouble(),
           let volume = (object.get(5) as? String)?.toDouble() {
            self.openTime = openTime
            self.openPrice = openPrice
            self.highPrice = highPrice
            self.lowPrice = lowPrice
            self.closePrice = closePrice
            self.volume = volume
        } else {
            return nil
        }
    }
}
