//
//  AddCoinPairCellView.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/21/21.
//

import Foundation

protocol AddCoinPairCellViewDelegate: class {
    func didTapAddCoinPair()
}

class AddCoinPairCellView: NSTableCellView {
    
    private lazy var button: NSButton = {
        let button = NSButton(title: "+", target: self, action: #selector(didTapButton))
        button.bezelStyle = .texturedSquare
        button.contentTintColor = .systemBlue
        return button
    }()
    
    weak var delegate: AddCoinPairCellViewDelegate?
    
    init() {
        super.init(frame: .zero)
        self.setupUIs()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUIs() {
        self.addSubview(button)

        button.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(self.snp.height).offset(-5)
        }
    }
    
    @objc private func didTapButton() {
        self.delegate?.didTapAddCoinPair()
    }
}
