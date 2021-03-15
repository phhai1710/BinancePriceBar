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
}
