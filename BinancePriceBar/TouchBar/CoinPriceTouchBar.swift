//
//  CoinPriceTouchBar.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/13/21.
//

import Foundation

class CoinPriceTouchBar: NSTouchBar {
    private lazy var pairsPriceController: PairsPriceController = {
        let pairsPriceController = PairsPriceController()
        pairsPriceController.delegate = self
        return pairsPriceController
    }()
    private var pairDetailController: PairDetailController?
    private var touchBarType = TouchBarType.coinPairs {
        didSet {
            self.reloadTouchBar()
        }
    }
    
    // MARK: - Constructors
    init(coinPairs: [CoinPairModel]) {
        super.init()
        self.updateCoinPairs(coinPairs: coinPairs)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func updateCoinPairs(coinPairs: [CoinPairModel]) {
        self.pairsPriceController.updateCoinPairs(coinPairs: coinPairs)
        if case .coinPairs = self.touchBarType {
            self.reloadTouchBar()
        }
    }
    
    func updatePairPrice(binanceCoinModel: BinanceCoinModel) {
        pairsPriceController.updatePairPrice(binanceCoinModel: binanceCoinModel)
        if pairDetailController?.coinPair.pair == binanceCoinModel.pair {
            pairDetailController?.updatePrice(binanceCoinModel: binanceCoinModel)
        }
    }
    
    func reloadTouchBar() {
        switch self.touchBarType {
        case .coinPairs:
            self.showTouchBarItem(items: pairsPriceController.getItems())
        case .pairDetail(let coinPair):
            let _pairDetailController = PairDetailController(coinPair: coinPair, delegate: self)
            self.pairDetailController = _pairDetailController
            self.showTouchBarItem(items: _pairDetailController.getItems())
        }
    }
    
    // MARK: - Private methods
    
    private func showTouchBarItem(items: [NSTouchBarItem]) {
        var items = items
        if AppSettings.showEsc {
            let escButton = NSButtonTouchBarItem(identifier: NSTouchBarItem.Identifier(rawValue: "ESC"),
                                                 title: "esc",
                                                 target: self,
                                                 action: #selector(didTapEsc))
            items.insert(escButton, at: 0)
        }
        templateItems = Set(items)
        defaultItemIdentifiers = items.map{ $0.identifier }
    }
    
    @objc private func didTapEsc() {
        let src = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: src, virtualKey: 53, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: src, virtualKey: 53, keyDown: false)

        let loc: CGEventTapLocation = .cghidEventTap
        keyDown?.post(tap: loc)
        keyUp?.post(tap: loc)
    }
}

extension CoinPriceTouchBar: PairsPriceProviderDelegate {
    func didTapPair(pair: CoinPairModel) {
        self.touchBarType = .pairDetail(coinPair: pair)
    }
}

extension CoinPriceTouchBar: PairDetailProviderDelegate {
    func dismissPairDetail() {
        self.pairDetailController = nil
        self.touchBarType = .coinPairs
    }
}

extension CoinPriceTouchBar {
    enum TouchBarType {
        case coinPairs
        case pairDetail(coinPair: CoinPairModel)
    }
}
