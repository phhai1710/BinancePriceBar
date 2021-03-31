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
        
        let closePrices = values.compactMap({ $0.closePrice })
        let chartEntries = closePrices.enumerated().map { ChartDataEntry(x: Double($0), y: $1) }
        
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
        
        var entries = self.getRsi(datas: values, length: 14)
        let max = closePrices.max() ?? 0
        let min = closePrices.min() ?? 0
        let maxRsi = entries.max() ?? 100
        let minRsi = entries.min() ?? 0
//        entries = entries.map { min + (max - min)*($0 / 100) }
        entries = entries.map { $0/(maxRsi + minRsi) * (max + min) }
        let rsiDataset = LineChartDataSet(entries: entries.enumerated().map({ ChartDataEntry(x: Double($0), y: $1) }))
        rsiDataset.drawFilledEnabled = true
        rsiDataset.drawCirclesEnabled = false
        rsiDataset.drawValuesEnabled = false
        rsiDataset.colors = [NSUIColor.red]
        rsiDataset.fill = Fill.fillWithColor(.clear)
        
        
        data.addDataSet(dataset)
        data.addDataSet(rsiDataset)
        
        lineChartView.data = data
    }
    
    // MARK: - Private methods
    private func calcSmmaUp(datas: [KLineChartModel], length n: Int, index i: Int, avgUt1: Double) -> Double {
        if avgUt1 == 0 {
            var sumUpChanges: Double = 0
            
            for j in 0..<n {
                let change: Double = datas[i - j].closePrice - datas[i - j].openPrice
                
                if(change > 0){
                    sumUpChanges += change
                }
            }
            return sumUpChanges / Double(n)
        } else {
            var change = datas[i].closePrice - datas[i].openPrice
            if change < 0 {
                change = 0
            }
            return ((avgUt1 * Double(n-1)) + change) / Double(n)
        }
    }

    private func calcSmmaDown(datas: [KLineChartModel], length n: Int, index i: Int, avgDt1: Double) -> Double {
        if avgDt1 == 0 {
            var sumDownChanges: Double = 0
            
            for j in 0..<n {
                let change: Double = datas[i - j].closePrice - datas[i - j].openPrice
                
                if change < 0 {
                    sumDownChanges -= change
                }
            }
            return sumDownChanges / Double(n);
        }else {
            var change: Double = datas[i].closePrice - datas[i].openPrice
            if change > 0 {
                change = 0
            }
            return ((avgDt1 * Double(n-1)) - change) / Double(n)
        }
        
    }
    
    public func getRsi(datas: [KLineChartModel], length: Int) -> [Double] {
        
        var results = Array<Double>()
        
        var ut1: Double = 0
        var dt1: Double = 0
        datas.enumerated().forEach { (index, data) in
            ut1 = index < length ? 1 : calcSmmaUp(datas: datas, length: length, index: index, avgUt1: ut1)
            dt1 = index < length ? 1 : calcSmmaDown(datas: datas, length: length, index: index, avgDt1: dt1)
            
            let result = 100.0 - 100.0 / (1.0 + ut1/dt1)
            results.append(result)
        }
        
        return results;
    }
    
    private func priceDataSet(chartEntries: [ChartDataEntry]) -> LineChartDataSet {
        let dataset = LineChartDataSet(entries: chartEntries)
        
        let gradientColors = [NSColor.cyan.cgColor, NSColor.green.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                       colors: gradientColors, locations: colorLocations) // Gradient Object
        if let gradient = gradient {
            dataset.fill = Fill.fillWithLinearGradient(gradient, angle: 90) // Set the Gradient
        } else {
            dataset.fill = Fill.fillWithColor(NSColor.cyan)
        }
        dataset.drawFilledEnabled = true
        dataset.drawCirclesEnabled = false
        dataset.drawValuesEnabled = false
        dataset.colors = [NSUIColor.yellow]
        
        return dataset
    }
    
    private func rsiDataSet() {
        
    }
    
    @objc private func didTapButton() {
        if let action = self.action {
            let object = target?.perform(action, with: self)
            _ = object?.autorelease()
        }
    }
}

class RsiModel {
    var lastSm: Double = 0
    var lastSa: Double = 0
    var rsi: [Double] = []
}
