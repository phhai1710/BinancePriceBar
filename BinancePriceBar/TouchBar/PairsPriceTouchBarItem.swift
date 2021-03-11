//
//  PairsPriceTouchBarItem.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/7/21.
//

import Cocoa
import Kingfisher

class PairsPriceTouchBarItem: NSTouchBarItem {
    
    let coinPair: CoinPairModel
    
    var price: String? {
        didSet {
            self.reloadText()
        }
    }
    
    private lazy var pairButton: NSButton = {
        let pairButton = NSButton()
        pairButton.bezelStyle = .rounded
        pairButton.bezelColor = NSColor(red: 54/255, green: 54/255, blue: 54/255, alpha: 1)
        pairButton.imagePosition = .imageLeft
        let size = CGSize(width: 20, height: 20)
        let resizeOption = KingfisherOptionsInfoItem.processor(DownsamplingImageProcessor(size: size))
        if !self.coinPair.iconData.isEmpty,
           let decodedData = Data(base64Encoded: self.coinPair.iconData, options: []) {
            let decodedimage = NSImage(data: decodedData)
            let provider = Base64ImageDataProvider(base64String: self.coinPair.iconData,
                                                   cacheKey: self.coinPair.iconData)
            pairButton.kf.setImage(with: .provider(provider),
                                   options: [resizeOption])
        } else if !self.coinPair.icon.isEmpty, let iconUrl = URL(string: self.coinPair.icon) {
            pairButton.kf.setImage(with: iconUrl,
                                   options: [resizeOption])
        }
        
        return pairButton
    }()
    
    override var view: NSView? {
        return pairButton
    }
    
    // MARK: - Constructors
    init(coinPair: CoinPairModel) {
        self.coinPair = coinPair
        super.init(identifier: NSTouchBarItem.Identifier(rawValue: self.coinPair.pair))
        pairButton.stringValue = identifier.rawValue
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Private methods
    private func reloadText() {
        guard let price = price else {
            return
        }
        if pairButton.image != nil {
            pairButton.title = price
        } else {
            let coinSymbol = self.coinPair.pair
            let string = "\(coinSymbol) \(price)"
            let attributedString = NSMutableAttributedString(string: string)
            attributedString.addAttribute(.foregroundColor, value: NSColor(hex: coinPair.colorHex), range: (string as NSString).range(of: coinSymbol))
            pairButton.attributedTitle = attributedString
        }
    }
}
