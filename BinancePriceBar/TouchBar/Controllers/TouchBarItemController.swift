//
//  TouchBarItemController.swift
//  BinancePriceBar
//
//  Created by Apple on 3/12/21.
//

import Foundation

protocol TouchBarItemController {
    func getItems() -> [NSTouchBarItem]
}
