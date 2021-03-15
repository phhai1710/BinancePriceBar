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
