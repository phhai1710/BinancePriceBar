//
//  RsiHelper.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 04/04/2021.
//

import Foundation

final class RsiHelper {
    static let shared = RsiHelper()
    
    public func getRsi(datas: [KLineChartModel], length: Int) -> [Double] {
        
        var results = Array<Double>()
        
        var ut1: Double = 0
        var dt1: Double = 0
        datas.enumerated().forEach { (index, data) in
            ut1 = calcSmmaUp(datas: datas, rsiLength: length, index: index, avgUt1: ut1)
            dt1 = calcSmmaDown(datas: datas, rsiLength: length, index: index, avgDt1: dt1)

            let result = 100.0 - 100.0 / (1.0 + ut1/dt1)
            results.append(result)
        }
        
        return results
    }
    
    private func calcSmmaUp(datas: [KLineChartModel], rsiLength: Int, index: Int, avgUt1: Double) -> Double {
        if avgUt1 == 0 {
            var sumUpChanges: Double = 0
            
            for j in 0..<rsiLength {
                if let data = datas.get(index - j) ?? datas.first {
                    let change: Double = data.closePrice - data.openPrice
                    if change > 0 {
                        sumUpChanges += change
                    }
                }
            }
            return sumUpChanges / Double(rsiLength)
        } else {
            var change = datas[index].closePrice - datas[index].openPrice
            if change < 0 {
                change = 0
            }
            return ((avgUt1 * Double(rsiLength-1)) + change) / Double(rsiLength)
        }
    }

    private func calcSmmaDown(datas: [KLineChartModel], rsiLength: Int, index: Int, avgDt1: Double) -> Double {
        if avgDt1 == 0 {
            var sumDownChanges: Double = 0
            
            for j in 0..<rsiLength {
                if let data = datas.get(index - j) ?? datas.first {
                    let change: Double = data.closePrice - data.openPrice
                    
                    if change < 0 {
                        sumDownChanges -= change
                    }
                }
            }
            return sumDownChanges / Double(rsiLength);
        } else {
            var change: Double = datas[index].closePrice - datas[index].openPrice
            if change > 0 {
                change = 0
            }
            return ((avgDt1 * Double(rsiLength-1)) - change) / Double(rsiLength)
        }
        
    }
}
