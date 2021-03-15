//
//  Double+Extensions.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/13/21.
//

import Foundation

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
    
    func toShortString() -> String {
        if self.truncatingRemainder(dividingBy: 1000000) > 0 {
            let millionValue = self / 1000000
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            if let result = formatter.string(from: NSNumber(value: millionValue)) {
                return result + "M"
            }
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            if let result = formatter.string(from: NSNumber(value: self)) {
                return result
            }
        }
        return self.roundToDecimal(2).description
    }
}
