//
//  ScrollTouchBarItem.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/11/21.
//

import Foundation

class ScrollTouchBarItem: NSCustomTouchBarItem {

    private let scrollView = NSScrollView(frame: .zero)
    
    init(identifier: NSTouchBarItem.Identifier, items: [NSTouchBarItem]) {
        super.init(identifier: identifier)
        view = scrollView
        self.updateItems(items: items)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateItems(items: [NSTouchBarItem]) {
        let views = items.compactMap { $0.view }
        let stackView = NSStackView(views: views)
        stackView.spacing = 1
        stackView.orientation = .horizontal
        scrollView.setFrameSize(stackView.fittingSize)
        scrollView.documentView = stackView
    }
}
