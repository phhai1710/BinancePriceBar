//
//  CoinPairCellView.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/21/21.
//

import Foundation

class CoinPairCellView: NSTableCellView {
    
    private lazy var label: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.alignment = .center
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        self.setupUIs()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUIs() {
        self.addSubview(label)

        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    func setTitle(string: String) {
        self.label.stringValue = string
    }
}
