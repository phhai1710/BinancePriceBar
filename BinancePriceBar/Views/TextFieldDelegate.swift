//
//  TextFieldDelegate.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/25/21.
//

import Foundation

class TextFieldDelegate: NSObject, NSTextFieldDelegate {
    
    private var textDidChanges: [NSTextField: ((String) -> Void)] = [:]
    private let textFields: Set<NSTextField> = Set()
    
    func addTextDidChangeListener(textField: NSTextField, textDidChange: @escaping (String) -> Void) {
        textDidChanges[textField] = textDidChange
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField, let textDidChange = textDidChanges[textField] {
            textDidChange(textField.stringValue)
        }
    }
}
