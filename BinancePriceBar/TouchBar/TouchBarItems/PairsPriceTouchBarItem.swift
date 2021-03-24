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
    
    weak var target: AnyObject?
    var action: Selector?
    
    private lazy var pairButton: NSButton = {
        let pairButton = NSButton()
        pairButton.title = coinPair.name.isNotEmpty() ? coinPair.name : coinPair.pair
        pairButton.bezelStyle = .rounded
        pairButton.font = NSFont.systemFont(ofSize: CGFloat(coinPair.fontSize), weight: .semibold)
        pairButton.bezelColor = Constants.buttonNormalColor
        pairButton.imagePosition = .imageLeft
        pairButton.imageScaling = .scaleProportionallyUpOrDown
        let size = CGSize(width: 80, height: 80)
        let resizeOption = KingfisherOptionsInfoItem.processor(DownsamplingImageProcessor(size: size))
        if let iconBase64String = self.coinPair.iconBase64String, !iconBase64String.isEmpty {
            let provider = Base64ImageDataProvider(base64String: iconBase64String,
                                                   cacheKey: iconBase64String)
            pairButton.kf.setImage(with: .provider(provider),
                                   options: [resizeOption])
        } else if !self.coinPair.iconUrl.isEmpty, let iconUrl = URL(string: self.coinPair.iconUrl) {
            pairButton.kf.setImage(with: iconUrl,
                                   options: [resizeOption])
        }
        pairButton.target = self
        pairButton.action = #selector(didTapButton)
        return pairButton
    }()
    
    override var view: NSView? {
        return pairButton
    }
    
    // MARK: - Constructors
    init(coinPair: CoinPairModel) {
        self.coinPair = coinPair
        super.init(identifier: NSTouchBarItem.Identifier(rawValue: self.coinPair.pair))
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Public methods
    func updatePrice(binanceCoinModel: BinanceCoinModel) {
        guard let price = binanceCoinModel.price else {
            return
        }
        let attributedString = NSMutableAttributedString()

        let percentChangeAttr = NSMutableAttributedString()
        if let percentChange = binanceCoinModel.pricePercentChange {
            percentChangeAttr.append(NSAttributedString(string: "("))
            let textColor = percentChange >= 0 ? NSColor.green : NSColor.red
            percentChangeAttr.append(NSAttributedString(string: "\(percentChange.roundToDecimal(2))%",
                                                        attributes: [.foregroundColor: textColor]))
            percentChangeAttr.append(NSAttributedString(string: ")"))
        }
        if pairButton.image == nil {
            let name = coinPair.name.isNotEmpty() ? coinPair.name : coinPair.pair
            let coinSymbolAttr = NSAttributedString(string: name,
                                                    attributes: [.foregroundColor: NSColor(hex: coinPair.colorHex)])
            attributedString.append(coinSymbolAttr)
            attributedString.append(NSAttributedString(string: " "))
        }
        attributedString.append(NSAttributedString(string: price.description))
        attributedString.append(percentChangeAttr)

        pairButton.attributedTitle = attributedString
        
        var isAboveAlertPrice = false
        var isBelowAlertPrice = false
        if let aboveAlertPrice = self.coinPair.aboveAlertPrice, price >= aboveAlertPrice {
            isAboveAlertPrice = true
        }
        if let aboveAlertPrice = self.coinPair.belowAlertPrice, price <= aboveAlertPrice {
            isBelowAlertPrice = true
        }
        
        pairButton.bezelColor = (isAboveAlertPrice || isBelowAlertPrice)
            ? Constants.buttonAlertColor : Constants.buttonNormalColor
    }
    
    // MARK: - Private methods
    
    @objc private func didTapButton() {
        if let action = self.action {
            let object = target?.perform(action, with: self)
            _ = object?.autorelease()
        }
    }
}
