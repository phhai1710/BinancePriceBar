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
    func setupChartDataSet(interval: String, values: [KLineChartModel]) {
        intervalLabel.stringValue = interval
        
        let chartEntries = self.chartDataEntries(datas: values)
        
        let priceDataSet = LineChartDataSet(entries: chartEntries.priceEntries)
        let gradientColors = [NSColor.cyan.cgColor, NSColor.green.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        if let gradient = gradient {
            priceDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90) // Set the Gradient
        } else {
            priceDataSet.fill = Fill.fillWithColor(NSColor.cyan)
        }
        priceDataSet.drawFilledEnabled = true
        priceDataSet.drawCirclesEnabled = false
        priceDataSet.drawValuesEnabled = false
        priceDataSet.colors = [NSUIColor.yellow]
        
        let rsiDataSet = LineChartDataSet(entries: chartEntries.rsiEntries)
        rsiDataSet.drawFilledEnabled = true
        rsiDataSet.drawCirclesEnabled = false
        rsiDataSet.drawValuesEnabled = false
        rsiDataSet.colors = [NSUIColor.red]
        rsiDataSet.fill = Fill.fillWithColor(.clear)
        
        let data = LineChartData()
        data.addDataSet(priceDataSet)
        data.addDataSet(rsiDataSet)
        
        lineChartView.data = data
    }
    
    // MARK: - Private methods
    
    private func chartDataEntries(datas: [KLineChartModel]) -> (priceEntries: [ChartDataEntry], rsiEntries: [ChartDataEntry]) {
        let closePrices = datas.compactMap({ $0.closePrice })
        var priceEntries = closePrices.enumerated().map { ChartDataEntry(x: Double($0), y: $1) }

        var rsiDatas = RsiHelper.shared.getRsi(datas: datas, length: AppSettings.rsiLength)
        let maxPrice = closePrices.max() ?? 0
        let minPrice = closePrices.min() ?? 0
        let maxRsi = rsiDatas.max() ?? 100
        let minRsi = rsiDatas.min() ?? 0
        rsiDatas = rsiDatas.map { $0/(maxRsi + minRsi) * (maxPrice - minPrice) + minPrice }
        var rsiEntries = rsiDatas.enumerated().map({ ChartDataEntry(x: Double($0), y: $1) })
        
        // Because rsi need previous data for calculation, very first datas will has wrong value
        priceEntries.removeFirst(AppSettings.rsiLength * 2)
        rsiEntries.removeFirst(AppSettings.rsiLength * 2)

        return (priceEntries, rsiEntries)
    }
    
    @objc private func didTapButton() {
        if let action = self.action {
            let object = target?.perform(action, with: self)
            _ = object?.autorelease()
        }
    }
}
