//
//  ChartTouchBarItem.swift
//  BinancePriceBar
//
//  Created by Apple on 3/14/21.
//

import Foundation
import Charts
import SnapKit

class ChartTouchBarItem: NSTouchBarItem {
    
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
        lineChartView.backgroundColor = NSColor(red: 54, green: 54, blue: 54)
        lineChartView.layer?.cornerRadius = 5
        lineChartView.snp.makeConstraints { (make) in
            make.width.equalTo(200)
        }
        return lineChartView
    }()
    
    override var view: NSView? {
        return lineChartView
    }
    
    func setupChartDataSet(values: [[Any]]) {
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
}
