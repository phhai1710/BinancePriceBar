//
//  NibLoadable.swift
//  BinancePriceBar
//
//  Created by Apple on 3/10/21.
//

import Foundation

protocol NibLoadable {
    // Name of the nib file
    static var nibName: String { get }
    static func createFromNib(in bundle: Bundle) -> Self
}

extension NibLoadable where Self: NSView {

    // Default nib name must be same as class name
    static var nibName: String {
        return String(describing: Self.self)
    }

    static func createFromNib(in bundle: Bundle = Bundle.main) -> Self {
        var topLevelArray: NSArray? = nil
        bundle.loadNibNamed(NSNib.Name(nibName), owner: self, topLevelObjects: &topLevelArray)
        let views = Array<Any>(topLevelArray!).filter { $0 is Self }
        return views.last as! Self
    }
}
