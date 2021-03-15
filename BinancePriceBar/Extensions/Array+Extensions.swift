//
//  Array+Extensions.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/14/21.
//

import Foundation

extension Array {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }

    func get(_ index: Int) -> Element? {
        if self.count > index && index >= 0 {
            return self[index]
        } else {
            return nil
        }
    }
}
