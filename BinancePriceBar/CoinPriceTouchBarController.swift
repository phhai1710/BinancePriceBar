//
//  CoinPriceTouchBarController.swift
//  CoinPriceBar
//
//  Created by Hai Pham on 3/7/21.
//

import Cocoa
import Starscream
import ObjectMapper

class CoinPriceTouchBarController: NSViewController {
    
    private var socket: WebSocket?
    private var coinPairs: [CoinPairModel]
    private lazy var pairPriceTouchBar = PairsPriceTouchBar(coinPairs: self.coinPairs)
    
    // MARK: - Constructors
    init(coinPairs: [CoinPairModel]) {
        self.coinPairs = coinPairs
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
        
    }
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        return pairPriceTouchBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initWebSocket()
    }
    
    func reloadJson(coinPairs: [CoinPairModel]) {
        self.coinPairs = coinPairs
        
        self.pairPriceTouchBar.updateItemList(coinPairs: coinPairs)
        self.initWebSocket()
    }
    
    private func initWebSocket() {
        socket?.disconnect()
        let pairStreams = coinPairs.map { self.getPairStream(coinPair: $0) }.joined(separator: "/")
        let urlString = "wss://stream.binance.com:9443/stream?streams=" + pairStreams
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.timeoutInterval = 5
            self.socket = WebSocket(request: request)
            socket?.delegate = self
            socket?.connect()
        }
    }
    
    private func getPairStream(coinPair: CoinPairModel) -> String {
        return "\(coinPair.pair.lowercased())@ticker"
    }
}

extension CoinPriceTouchBarController: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let dict):
            print("Connected \(dict)")
        case .disconnected(let string, _):
            print("disconnected \(string)")
        case .text(let string):
            let model = Mapper<BinanceCoinModel>().map(JSONString: string)
            if let pair = model?.pair, let price = model?.price, let priceD = Double(price) {
                pairPriceTouchBar.setPrice(pair: pair, price: priceD.description)
            }
            print("text \(string)")
        case .pong(_):
            print("pong")
        case .ping(_):
            print("ping")
        case .error(let error):
            print("error \(error?.localizedDescription ?? "")")
        default:
            print(event)
        }
    }
}
