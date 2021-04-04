//
//  String+Extensions.swift
//  BinancePriceBar
//
//  Created by Apple on 3/14/21.
//

import Foundation

extension String {
    func isNotEmpty() -> Bool {
        return !self.isEmpty
    }
    
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Converts String to Int
    func toInt() -> Int? {
        return Int(self)
    }

    /// Converts String to Double
    func toDouble() -> Double? {
        return Double(self)
    }

    /// Converts String to Float
    func toFloat() -> Float? {
        return Float(self)
    }
}
