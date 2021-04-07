//
//  CoinPairsViewController.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/16/21.
//

import Foundation
import Kingfisher

class CoinPairsViewController: NSViewController {
    private static let coinPairPasteBoard = NSPasteboard.PasteboardType("preferences.coinpair")
    
    @IBOutlet weak var tableView: NSTableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
            tableView.sizeLastColumnToFit()
            tableView.registerForDraggedTypes([CoinPairsViewController.coinPairPasteBoard])
        }
    }
    @IBOutlet weak var enableButton: NSButton!
    @IBOutlet weak var pairTextField: NSTextField!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var uploadIconButton: NSButton! {
        didSet {
            uploadIconButton.target = self
            uploadIconButton.action = #selector(didTapUploadIcon)
        }
    }
    private var selectedIconBase64String: String?
    @IBOutlet weak var iconUrlTextField: NSTextField!
    @IBOutlet weak var colorPicker: NSColorWell!
    @IBOutlet weak var aboveAlertTextField: NSTextField!
    @IBOutlet weak var belowAlertTextField: NSTextField!
    @IBOutlet weak var fontSizeButton: NSPopUpButton! {
        didSet {
            fontSizeButton.addItems(withTitles: (9...16).map { $0.description })
        }
    }
    @IBOutlet weak var cancelButton: NSButton! {
        didSet {
            cancelButton.target = self
            cancelButton.action = #selector(didTapCancel)
        }
    }
    @IBOutlet weak var saveButton: NSButton! {
        didSet {
            saveButton.target = self
            saveButton.action = #selector(didTapSave)
        }
    }
    @IBOutlet weak var deleteButton: NSButtonCell! {
        didSet {
            deleteButton.target = self
            deleteButton.action = #selector(didTapDelete)
        }
    }
    private var textFieldDelegate = TextFieldDelegate()

    private var currentSelectedRow: Int?
    
    private var coinPairs = AppSettings.coinPairs
    
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Private methods
    private func setupUIs() {
        
    }
    
    private func fillData(for coinPair: CoinPairModel?) {
        if let coinPair = coinPair {
            self.enableButton.state = coinPair.enable ? .on : .off
            self.pairTextField.stringValue = coinPair.pair
            self.nameTextField.stringValue = coinPair.name
            self.setSelectedIcon(iconBase64String: coinPair.iconBase64String)
            self.iconUrlTextField.stringValue = coinPair.iconUrl
            self.colorPicker.color = NSColor(hex: coinPair.colorHex)
            if let aboveAlertPrice = coinPair.aboveAlertPrice {
                self.aboveAlertTextField.stringValue = String(aboveAlertPrice)
            } else {
                self.aboveAlertTextField.stringValue = ""
            }
            if let belowAlertPrice = coinPair.belowAlertPrice {
                self.belowAlertTextField.stringValue = String(belowAlertPrice)
            } else {
                self.belowAlertTextField.stringValue = ""
            }
            self.fontSizeButton.selectItem(withTitle: coinPair.fontSize.description)
        } else {
            self.enableButton.state = .off
            self.pairTextField.stringValue = ""
            self.nameTextField.stringValue = ""
            self.setSelectedIcon(iconBase64String: nil)
            self.iconUrlTextField.stringValue = ""
            self.aboveAlertTextField.stringValue = ""
            self.belowAlertTextField.stringValue = ""
        }
    }
    
    private func setSelectedIcon(iconBase64String: String?) {
        if let iconBase64String = iconBase64String, !iconBase64String.isEmpty {
            let provider = Base64ImageDataProvider(base64String: iconBase64String,
                                                   cacheKey: iconBase64String)
            self.uploadIconButton.kf.setImage(with: .provider(provider),
                                              placeholder: NSImage(named: "ic_upload_icon"),
                                              completionHandler:  { (result) in
                                                switch result {
                                                case .success(_):
                                                    self.selectedIconBase64String = iconBase64String
                                                case .failure(_):
                                                    self.selectedIconBase64String = nil
                                                }
                                              })
        } else {
            self.uploadIconButton.image = NSImage(named: "ic_upload_icon")
            self.selectedIconBase64String = nil
        }
    }
}

extension CoinPairsViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 40
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.coinPairs.count + 1
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if row == self.numberOfRows(in: tableView) - 1 {
            var cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("AddCoinPairCellView"), owner: nil) as? AddCoinPairCellView
            if cell == nil {
                cell = AddCoinPairCellView()
                cell?.identifier = NSUserInterfaceItemIdentifier("AddCoinPairCellView")
            }
            cell?.delegate = self
            return cell
        } else if let coinPair = self.coinPairs.get(row) {
            var cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("CoinPairCellView"), owner: nil) as? CoinPairCellView
            if cell == nil {
                cell = CoinPairCellView()
                cell?.identifier = NSUserInterfaceItemIdentifier("CoinPairCellView")
            }
            cell?.setTitle(string: coinPair.pair)
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if row == self.numberOfRows(in: tableView) - 1 {
            return false
        }
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        // Save data of current row
        self.didTapSave()
        // Fill data of new selected row
        let selectedRow = tableView.selectedRow
        if selectedRow == -1 {
            self.currentSelectedRow = nil
            self.fillData(for: nil)
        } else if let coinPair = self.coinPairs.get(selectedRow) {
            self.currentSelectedRow = selectedRow
            self.fillData(for: coinPair)
        }
    }
    
    // Handle reorder
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        if let rowData = try? NSKeyedArchiver.archivedData(withRootObject: rowIndexes, requiringSecureCoding: false) {
            pboard.declareTypes([CoinPairsViewController.coinPairPasteBoard], owner: self)
            pboard.setData(rowData, forType: CoinPairsViewController.coinPairPasteBoard)
            return true
        } else {
            return false
        }
        
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        return .every
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        let pboard = info.draggingPasteboard
        if let rowData = pboard.data(forType: CoinPairsViewController.coinPairPasteBoard),
           let rowIndexes = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSIndexSet.self, from: rowData) {
            let dragRow = rowIndexes.firstIndex
            
            if dragRow < row {
                self.coinPairs.insert(self.coinPairs[dragRow], at: row)
                self.coinPairs.remove(at: dragRow)
                
                tableView.noteNumberOfRowsChanged()
                tableView.moveRow(at: dragRow, to: row - 1)
            } else {
                let temp = self.coinPairs[dragRow]
                self.coinPairs.remove(at: dragRow)
                self.coinPairs.insert(temp, at: row)

                tableView.noteNumberOfRowsChanged()
                tableView.moveRow(at: dragRow, to: row)
            }
            AppSettings.coinPairs = self.coinPairs
            (NSApplication.shared.delegate as? AppDelegate)?.reloadTouchBar()
            return true
        } else {
            return false
        }
        
    }
}

// MARK: - AddCoinPairCellViewDelegate
extension CoinPairsViewController: AddCoinPairCellViewDelegate {
    func didTapAddCoinPair() {
        
        if let window = view.window {
            let alert = NSAlert()
            alert.messageText = "Please enter the coin pair"
            alert.alertStyle = .informational
            let okButton = alert.addButton(withTitle: "OK")
            okButton.isEnabled = false
            alert.addButton(withTitle: "Cancel")
            let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            textField.placeholderString = "BTCUSDT"
            textField.stringValue = ""
            self.textFieldDelegate.addTextDidChangeListener(textField: textField) { (stringValue) in
                okButton.isEnabled = stringValue.trimmed().isNotEmpty()
            }
            textField.delegate = self.textFieldDelegate
            alert.accessoryView = textField
            alert.beginSheetModal(for: window) { [weak self] (response) in
                guard let strongSelf = self else {
                    return
                }
                switch response {
                case .alertFirstButtonReturn:
                    if strongSelf.coinPairs.contains(where: { $0.pair == textField.stringValue.trimmed() }) {
                        let alert = NSAlert()
                        alert.messageText = "\(textField.stringValue.trimmed()) is exists!"
                        alert.alertStyle = .warning
                        alert.beginSheetModal(for: window, completionHandler: nil)
                    } else {
                        let coinPair = CoinPairModel(pair: textField.stringValue.trimmed(), colorHex: "fcba03")
                        strongSelf.coinPairs.append(coinPair)
                        AppSettings.coinPairs = strongSelf.coinPairs
                        strongSelf.tableView.reloadData()
                        strongSelf.tableView.selectRowIndexes(IndexSet(integer: strongSelf.coinPairs.count - 1),
                                                              byExtendingSelection: false)
                    }
                default:
                    break
                }
            }
        }
    }
}

// MARK: - Action selectors
extension CoinPairsViewController {
    @objc private func didTapSave() {
        if let currentSelectedRow = self.currentSelectedRow,
           let coinPair = self.coinPairs.get(currentSelectedRow) {
            
            if pairTextField.stringValue.trimmed().isEmpty {
                let alert = NSAlert()
                alert.messageText = "The coin pair field is required!"
                alert.addButton(withTitle: "OK")
                alert.runModal()
                return
            }
            
            let enable = enableButton.state == .on ? true : false
            let pair = pairTextField.stringValue
            let name = nameTextField.stringValue
            let iconUrl = iconUrlTextField.stringValue
            let iconBase64String = self.selectedIconBase64String
            let colorHex = colorPicker.color.hexString()
            let aboveAlertPrice = aboveAlertTextField.stringValue.trimmed().toDouble()
            let belowAlertPrice = belowAlertTextField.stringValue.trimmed().toDouble()
            let fontSize = fontSizeButton.titleOfSelectedItem?.toInt() ?? 14
            
            var hasChanged = false
            if coinPair.enable != enable
                || coinPair.pair != pair
                || coinPair.name != name
                || coinPair.iconUrl != iconUrl
                || coinPair.iconBase64String != iconBase64String
                || coinPair.colorHex != colorHex
                || coinPair.aboveAlertPrice != aboveAlertPrice
                || coinPair.belowAlertPrice != belowAlertPrice
                || coinPair.fontSize != fontSize {
                hasChanged = true
            }
            
            coinPair.enable = enable
            coinPair.pair = pair
            coinPair.name = name
            coinPair.iconUrl = iconUrl
            coinPair.iconBase64String = iconBase64String
            coinPair.colorHex = colorHex
            coinPair.aboveAlertPrice = aboveAlertPrice
            coinPair.belowAlertPrice = belowAlertPrice
            coinPair.fontSize = fontSize
            
            AppSettings.coinPairs = self.coinPairs
            self.tableView.reloadData(forRowIndexes: IndexSet(integer: currentSelectedRow), columnIndexes: IndexSet(integer: 0))
            if hasChanged {
                (NSApplication.shared.delegate as? AppDelegate)?.reloadTouchBar()
            }
        }
    }
    
    @objc private func didTapCancel() {
        if let currentSelectedRow = self.currentSelectedRow,
           let coinPair = self.coinPairs.get(currentSelectedRow) {
            self.fillData(for: coinPair)
        }
    }
    
    @objc private func didTapDelete() {
        if let currentSelectedRow = self.currentSelectedRow,
           let _ = self.coinPairs.get(currentSelectedRow),
           let window = view.window {
            let alert = NSAlert()
            alert.messageText = "Delete this pair?"
            let okButton = alert.addButton(withTitle: "OK")
            let cancelButton = alert.addButton(withTitle: "Cancel")
            okButton.keyEquivalent = ""
            cancelButton.keyEquivalent = "\r"
            alert.alertStyle = .warning
            alert.beginSheetModal(for: window) { (response) in
                if response == .alertFirstButtonReturn {
                    if let currentSelectedRow = self.currentSelectedRow,
                       self.coinPairs.count > currentSelectedRow {
                        self.coinPairs.remove(at: currentSelectedRow)
                        self.currentSelectedRow = nil
                        AppSettings.coinPairs = self.coinPairs
                        self.tableView.reloadData()
                        self.fillData(for: nil)
                                                
                        (NSApplication.shared.delegate as? AppDelegate)?.reloadTouchBar()
                    }
                }
            }
        }
    }
    @objc private func didTapUploadIcon() {
        func showWindowSelectFile() {
            let dialog = NSOpenPanel()
            dialog.title = "Choose an icon"
            dialog.showsResizeIndicator = true
            dialog.showsHiddenFiles = false
            dialog.canChooseDirectories = false
            dialog.canCreateDirectories = false
            dialog.allowsMultipleSelection = false
            dialog.allowedFileTypes = ["png", "jpg", "PNG", "bmp", "JPEG"]
            
            if dialog.runModal() == .OK {
                if let url = dialog.url, let image = NSImage(contentsOf: url) {
                    self.setSelectedIcon(iconBase64String: image.resize(w: 80, h: 80).pngData?.base64EncodedString())
                } else {
                    let alert = NSAlert()
                    alert.messageText = "Can not open the selected file!"
                    alert.addButton(withTitle: "OK")
                    if let window = view.window {
                        alert.beginSheetModal(for: window, completionHandler: nil)
                    } else {
                        alert.runModal()
                    }
                }
            }
        }
        if let window = view.window, self.selectedIconBase64String != nil {
            let alert = NSAlert()
            alert.messageText = "Please select an option!"
            alert.addButton(withTitle: "Upload")
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Remove")
            alert.alertStyle = .informational
            alert.beginSheetModal(for: window) { (response) in
                switch response {
                case .alertFirstButtonReturn:
                    showWindowSelectFile()
                case .alertSecondButtonReturn:
                    break
                case .alertThirdButtonReturn:
                    self.setSelectedIcon(iconBase64String: nil)
                default:
                    break
                }
            }
        } else {
            showWindowSelectFile()
        }
    }
}
