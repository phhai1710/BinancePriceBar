//
//  AppSettings.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 2/28/21.
//

import Foundation

struct AppSettings {
    @UserDefault(key: "showControlStrip", defaultValue: false)
    static var showControlStripState: Bool
    
    @UserDefault(key: "showEsc", defaultValue: false)
    static var showEsc: Bool
    
    public static var chartInterval: PresetModel.ChartInterval {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "chartInterval")
        }
        get {
            if let string = UserDefaults.standard.string(forKey: "chartInterval") {
                return PresetModel.ChartInterval(rawValue: string) ?? .h1
            }
            return .h1
        }
    }
    
    @UserDefault(key: "rsiLength", defaultValue: 14)
    static var rsiLength: Int
    
    public static var coinPairs: [CoinPairModel] {
        get
        {
            guard let data = UserDefaults.standard.data(forKey: "coinPairs") else {
                return []
            }
            return (try? JSONDecoder().decode([CoinPairModel].self, from: data)) ?? []
        }
        set
        {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }
            UserDefaults.standard.set(data, forKey: "coinPairs")
        }
    }
}

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
}
