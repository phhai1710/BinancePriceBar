//
//  AppSettings.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 2/28/21.
//

import Foundation

struct AppSettings {
    @UserDefault(key: "com.phhai.settings.showControlStrip", defaultValue: false)
    static var showControlStripState: Bool
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
