//
//  ChartTouchBarItem.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/14/21.
//

import Foundation
import Charts
import SnapKit

class ChartTouchBarItem: NSTouchBarItem {
    
    private lazy var containerView: NSButton = {
        let containerView = NSButton()
        containerView.title = ""
        containerView.bezelStyle = .rounded
        containerView.bezelColor = Constants.buttonNormalColor
        containerView.target = self
        containerView.action = #selector(didTapButton)
        return containerView
    }()
    
    private lazy var lineChartView: LineChartView = {
        let lineChartView = LineChartView()
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.legend.enabled = false
        lineChartView.minOffset = 0
        lineChartView.backgroundColor = .clear
        lineChartView.layer?.cornerRadius = 5
        
        return lineChartView
    }()
    
    private lazy var intervalLabel: NSTextField = {
        let intervalLabel = NSTextField()
        intervalLabel.textColor = .yellow
        intervalLabel.font = NSUIFont.systemFont(ofSize: 14)
        intervalLabel.alignment = .center
        return intervalLabel
    }()
    
    weak var target: AnyObject?
    var action: Selector?
    
    override var view: NSView? {
        return containerView
    }
    
    
    // MARK: - Constructors
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        
        self.containerView.addSubview(self.lineChartView)
        self.containerView.addSubview(self.intervalLabel)
        
        
        self.lineChartView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalTo(200)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.intervalLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.lineChartView.snp.trailing)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func setupChartDataSet(interval: String, values: [[Any]]) {
        intervalLabel.stringValue = interval
        
        let closePrices = values.compactMap({ $0.get(4) as? String })
        let chartEntries = closePrices.enumerated().compactMap { index, value -> ChartDataEntry? in
            if let double = Double(value) {
                return ChartDataEntry(x: Double(index), y: double)
            }
            return nil
        }
        
        let data = LineChartData()
        let dataset = LineChartDataSet(entries: chartEntries)
        
        let gradientColors = [NSColor.cyan.cgColor, NSColor.green.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        if let gradient = gradient {
            dataset.fill = Fill.fillWithLinearGradient(gradient, angle: 90) // Set the Gradient
        } else {
            dataset.fill = Fill.fillWithColor(NSColor.cyan)
        }
        dataset.drawFilledEnabled = true
        
        
        dataset.drawCirclesEnabled = false
        dataset.drawValuesEnabled = false
        dataset.colors = [NSUIColor.yellow]
        data.addDataSet(dataset)
        
        lineChartView.data = data
    }
    
    // MARK: - Private methods
    @objc private func didTapButton() {
        if let action = self.action {
            let object = target?.perform(action, with: self)
            _ = object?.autorelease()
        }
    }
}
