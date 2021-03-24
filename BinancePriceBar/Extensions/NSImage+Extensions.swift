//
//  Image+Extensions.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/22/21.
//

import Foundation

extension NSImage {
    func resize(w: Int, h: Int) -> NSImage {
        let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        self.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height),
                   from: NSMakeRect(0, 0, self.size.width, self.size.height),
                   operation: NSCompositingOperation.sourceOver,
                   fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        return newImage
    }
}

extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
    var pngData: Data? { tiffRepresentation?.bitmap?.png }
}
