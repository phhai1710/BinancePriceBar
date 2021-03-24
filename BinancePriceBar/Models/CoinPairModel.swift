//
//  CoinPair.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/7/21.
//

class CoinPairModel: NSObject, NSCoding, Decodable, Encodable {
    
    var pair: String = ""
    var name: String = ""
    var iconUrl: String = ""
    var iconBase64String: String?
    var colorHex: String = ""
    var aboveAlertPrice: Double?
    var belowAlertPrice: Double?
    var enable: Bool = true
    var fontSize: Int = 14

    init(pair: String, colorHex: String) {
        self.pair = pair
        self.colorHex = colorHex
    }
    
    required init?(coder encode: NSCoder) {
        guard let pair = encode.decodeObject(forKey: "pair") as? String else {
            return nil
        }
        self.pair = pair
        self.name = encode.decodeObject(forKey: "name") as? String ?? ""
        self.iconUrl = encode.decodeObject(forKey: "iconUrl") as? String ?? ""
        self.iconBase64String = encode.decodeObject(forKey: "iconBase64String") as? String
        self.colorHex = encode.decodeObject(forKey: "colorHex") as? String ?? ""
        self.aboveAlertPrice = encode.decodeObject(forKey: "aboveAlertPrice") as? Double
        self.belowAlertPrice = encode.decodeObject(forKey: "belowAlertPrice") as? Double
        self.enable = encode.decodeObject(forKey: "enable") as? Bool ?? true
        self.fontSize = encode.decodeObject(forKey: "fontSize") as? Int ?? 14
    }
    
    
    func encode(with coder: NSCoder) {
        coder.encode(pair, forKey: "pair")
        coder.encode(iconUrl, forKey: "iconUrl")
        coder.encode(iconBase64String, forKey: "iconBase64String")
        coder.encode(colorHex, forKey: "colorHex")
        coder.encode(aboveAlertPrice, forKey: "aboveAlertPrice")
        coder.encode(belowAlertPrice, forKey: "belowAlertPrice")
        coder.encode(enable, forKey: "enable")
        coder.encode(fontSize, forKey: "fontSize")
    }
    
    static func == (lhs: CoinPairModel, rhs: CoinPairModel) -> Bool {
        return lhs.pair == rhs.pair
    }
}
