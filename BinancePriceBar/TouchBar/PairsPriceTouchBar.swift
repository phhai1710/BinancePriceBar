//
//  PairsPriceTouchBar.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/7/21.
//

import Cocoa

class PairsPriceTouchBar: NSTouchBar {
    
    private var items: [PairsPriceTouchBarItem] = []
    
    init(coinPairs: [CoinPairModel]) {
        super.init()
        self.updateItemList(coinPairs: coinPairs)
    }
    
    func updateItemList(coinPairs: [CoinPairModel]) {
        items = coinPairs.map({PairsPriceTouchBarItem(coinPair: $0)})
        let scrollItem = ScrollTouchBarItem(identifier: NSTouchBarItem.Identifier(rawValue: UUID().uuidString),
                                            items: items)
        templateItems = Set([scrollItem])
        defaultItemIdentifiers = [scrollItem].map{ $0.identifier }
    }
    
    func setPrice(pair: String, price: String) {
        items.first(where: { $0.coinPair.pair == pair })?.price = price
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
