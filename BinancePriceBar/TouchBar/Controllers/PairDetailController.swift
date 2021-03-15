//
//  PairDetailController.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/12/21.
//

import Foundation
import Charts
import Alamofire
import ObjectMapper

protocol PairDetailProviderDelegate: class {
    func dismissPairDetail()
}

class PairDetailController: TouchBarItemController {
    let coinPair: CoinPairModel
    private let scrollItem = ScrollTouchBarItem(identifier: NSTouchBarItem.Identifier(rawValue: UUID().uuidString),
                                                items: [])

    private lazy var pairItem: PairsPriceTouchBarItem = {
        let pairItem = PairsPriceTouchBarItem(coinPair: self.coinPair)
        pairItem.target = self
        pairItem.action = #selector(didTapCollapse)
        return pairItem
    }()
    private lazy var vol24hItem: NSButtonTouchBarItem = {
        let vol24hItem = NSButtonTouchBarItem(identifier: NSTouchBarItem.Identifier(coinPair.pair + "vol24h"),
                                              title: "Volume: 0",
                                              target: nil,
                                              action: nil)
        return vol24hItem
    }()
    private lazy var chartItem: ChartTouchBarItem = {
        let chartItem = ChartTouchBarItem(identifier: NSTouchBarItem.Identifier(coinPair.pair + "chart"))
        return chartItem
    }()
    weak var delegate: PairDetailProviderDelegate?
    
    init(coinPair: CoinPairModel, delegate: PairDetailProviderDelegate) {
        self.coinPair = coinPair
        self.delegate = delegate
        self.scrollItem.updateItems(items: [pairItem, vol24hItem])
        self.getChartData()
    }
    
    // MARK: - Public methods
    
    func getItems() -> [NSTouchBarItem] {
        return [scrollItem]
    }
    
    func updatePrice(binanceCoinModel: BinanceCoinModel) {
        pairItem.updatePrice(binanceCoinModel: binanceCoinModel)
        vol24hItem.title = "Volume: \(binanceCoinModel.vol24h?.toShortString() ?? "0")"
    }
    
    // MARK: - Private methods
    
    private func getChartData() {
        AF.request("https://api.binance.com/api/v3/klines?symbol=\(self.coinPair.pair)&interval=\(AppSettings.chartInterval.intervalValue())&limit=100").response { [weak self] (response) in
            guard let strongSelf = self else {
                return
            }
            switch response.result {
            case .success(let data):
                if let data = data,
                   let chartData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[Any]] {
                    strongSelf.chartItem.setupChartDataSet(values: chartData)
                    strongSelf.scrollItem.updateItems(items: [strongSelf.pairItem, strongSelf.vol24hItem, strongSelf.chartItem])
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func didTapCollapse() {
        self.delegate?.dismissPairDetail()
    }
}
