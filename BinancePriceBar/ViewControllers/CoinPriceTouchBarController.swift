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
    private static let delay1min: TimeInterval = 60
    private static let delay2min: TimeInterval = 120
    private static let delay5min: TimeInterval = 300
    private static let delay10min: TimeInterval = 600

    
    private var socket: WebSocket?
    private var coinPairs: [CoinPairModel]
    private lazy var coinPriceTouchBar: CoinPriceTouchBar = {
        let coinPriceTouchBar = CoinPriceTouchBar(coinPairs: coinPairs)
        return coinPriceTouchBar
    }()
    private var shouldReconnect = false
    private var numberOfRetries = 0
    private var delayRetry: [TimeInterval] = [CoinPriceTouchBarController.delay1min,
                                              CoinPriceTouchBarController.delay2min,
                                              CoinPriceTouchBarController.delay5min,
                                              CoinPriceTouchBarController.delay10min]

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
        return coinPriceTouchBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initWebSocket()
        
        NSWorkspace.shared.notificationCenter.addObserver(self,
                                                          selector: #selector(onWakeNote(note:)),
                                                          name: NSWorkspace.didWakeNotification,
                                                          object: nil)
        
        NSWorkspace.shared.notificationCenter.addObserver(self,
                                                          selector: #selector(onSleepNote(note:)),
                                                          name: NSWorkspace.willSleepNotification,
                                                          object: nil)
    }
    
    func reloadCoinPairs(coinPairs: [CoinPairModel]) {
        self.coinPairs = coinPairs
        
        self.coinPriceTouchBar.updateCoinPairs(coinPairs: coinPairs)
        self.initWebSocket()
    }
    
    func reloadTouchBar() {
        coinPriceTouchBar.reloadTouchBar()
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
    
    private func resetDelay() {
        self.numberOfRetries = 0
        self.delayRetry = [CoinPriceTouchBarController.delay1min,
                           CoinPriceTouchBarController.delay2min,
                           CoinPriceTouchBarController.delay5min,
                           CoinPriceTouchBarController.delay10min]
    }
}

extension CoinPriceTouchBarController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocketDidConnect")
        self.resetDelay()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocketDidDisconnect")
        if self.numberOfRetries < 5 {
            self.numberOfRetries += 1
            socket.connect()
        } else {
            // Waiting for 1/2.5/5/10 mins
            var waitingTime = CoinPriceTouchBarController.delay10min
            if delayRetry.count > 1 {
                waitingTime = delayRetry.removeFirst()
            } else if let _waitingTime = delayRetry.first {
                waitingTime = _waitingTime
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + waitingTime) {
                self.numberOfRetries = 0
                socket.connect()
            }
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let model = Mapper<BinanceCoinModel>().map(JSONString: text) {
            coinPriceTouchBar.updatePairPrice(binanceCoinModel: model)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocketDidReceiveData \(String(data: data, encoding: .utf8) ?? "")")
    }
    
      // TODO: Starscream v4.0.4
//    func didReceive(event: WebSocketEvent, client: WebSocket) {
//        switch event {
//        case .connected(let dict):
//            print("Connected \(dict)")
//        case .disconnected(let string, _):
//            print("disconnected \(string)")
//        case .text(let string):
//            if let model = Mapper<BinanceCoinModel>().map(JSONString: string) {
//                coinPriceTouchBar.updatePairPrice(binanceCoinModel: model)
//            }
////            print("text \(string)")
//        case .pong(_):
//            print("pong")
//        case .ping(_):
//            print("ping")
//        case .error(let error):
//            print("error \(error?.localizedDescription ?? "")")
//        case .viabilityChanged(let viablity):
//            print("viabilityChanged \(viablity)")
//            if !viablity {
//                // Disconnect current session and reconnect again
//                self.shouldReconnect = true
//                client.disconnect()
//            }
//        case .reconnectSuggested(let status):
//            print("reconnectSuggested \(status)")
//        case .cancelled:
//            print("cancelled")
//            if self.shouldReconnect {
//                self.shouldReconnect = false
//                client.connect()
//            }
//        default:
//            print(event)
//        }
//    }
}

// MARK: - Notification selectors
extension CoinPriceTouchBarController {
    @objc func onWakeNote(note: NSNotification) {
        print("wake up")
        self.socket?.connect()
    }

    @objc func onSleepNote(note: NSNotification) {
        print("sleep")
        self.socket?.disconnect()
    }
}
