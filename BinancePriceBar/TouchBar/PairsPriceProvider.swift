//
//  PairsPriceController.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/11/21.
//

import Foundation

protocol PairsPriceProviderDelegate: class {
    func didTapPair(pair: CoinPairModel)
}

class PairsPriceController: TouchBarItemController {
    
    private let coinPairs: [CoinPairModel]
    private var itemsDict: [String: PairsPriceTouchBarItem] = [:]
    weak var delegate: PairsPriceProviderDelegate?
    
    init(coinPairs: [CoinPairModel], delegate: PairsPriceProviderDelegate) {
        self.coinPairs = coinPairs
        self.delegate = delegate
    }
    
    func updatePairPrice(binanceCoinModel: BinanceCoinModel) {
        if let pair = binanceCoinModel.pair {
            itemsDict[pair]?.updatePrice(binanceCoinModel: binanceCoinModel)
        }
    }
    
    func getItems() -> [NSTouchBarItem] {
        var items = [PairsPriceTouchBarItem]()
        coinPairs.forEach { (coinPair) in
            let touchBarItem = PairsPriceTouchBarItem(coinPair: coinPair)
            touchBarItem.action = #selector(didTapTouchBarItem)
            touchBarItem.target = self
            itemsDict[coinPair.pair] = touchBarItem
            items.append(touchBarItem)
        }
        let scrollItem = ScrollTouchBarItem(identifier: NSTouchBarItem.Identifier(rawValue: UUID().uuidString),
                                            items: items)
        return [scrollItem]
    }
    
    // MARK: - Private methods
    @objc private func didTapTouchBarItem(item: PairsPriceTouchBarItem) {
        delegate?.didTapPair(pair: item.coinPair)
    }
}
