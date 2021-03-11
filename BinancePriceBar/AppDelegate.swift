//
//  AppDelegate.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/8/21.
//

import Cocoa
import ObjectMapper

let appSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!.appending("/BinancePriceBar")
let standardConfigPath = appSupportDirectory.appending("/items.json")

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    private let btcCharacter = "₿"
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    private let coinPriceTouchBarController = CoinPriceTouchBarController(coinPairs: [])
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
        let customTouchBarItem = NSCustomTouchBarItem(identifier: NSTouchBarItem.Identifier(rawValue: btcCharacter))
        let customTouchBarItemButton = NSButton(title: btcCharacter, target: self, action: #selector(self.customTouchBarItemTapped))
        customTouchBarItem.view = customTouchBarItemButton
        NSTouchBarItem.addSystemTrayItem(customTouchBarItem)
        DFRElementSetControlStripPresenceForIdentifier(NSTouchBarItem.Identifier(rawValue: customTouchBarItem.identifier.rawValue), true)
        
        window = NSWindow(contentViewController: coinPriceTouchBarController)
        window.touchBar = coinPriceTouchBarController.touchBar
        window.makeKeyAndOrderFront(nil)
        
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("ic_status_bar"))
        }
        AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true] as NSDictionary)
        createMenu()
        reloadStandardConfig()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc private func customTouchBarItemTapped() {
        NSTouchBar.presentSystemModalTouchBar(coinPriceTouchBarController.touchBar, systemTrayItemIdentifier: NSTouchBarItem.Identifier(rawValue: btcCharacter))
    }
    
    func reloadStandardConfig() {
        let presetPath = standardConfigPath
        if !FileManager.default.fileExists(atPath: presetPath),
            let defaultPreset = Bundle.main.path(forResource: "defaultPreset", ofType: "json") {
            try? FileManager.default.createDirectory(atPath: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            try? FileManager.default.copyItem(atPath: defaultPreset, toPath: presetPath)
        }

        if let data = try? Data(contentsOf:  URL(fileURLWithPath: presetPath), options: .mappedIfSafe),
           let jsonString = String(data: data, encoding: .utf8),
           let preset = PresetModel(JSONString: jsonString) {
            coinPriceTouchBarController.reloadJson(coinPairs: preset.coinPairs)
        }
    }
    
    func createMenu() {
        let menu = NSMenu()
        
        let startAtLogin = NSMenuItem(title: "Start at login", action: #selector(toggleStartAtLogin(_:)), keyEquivalent: "L")
        startAtLogin.state = LaunchAtLoginController().launchAtLogin ? .on : .off
        
        let settingSeparator = NSMenuItem(title: "Settings", action: nil, keyEquivalent: "")
        settingSeparator.isEnabled = false
        
        menu.addItem(withTitle: "Preferences", action: #selector(openPreferences(_:)), keyEquivalent: ",")
        menu.addItem(withTitle: "Open preset", action: #selector(openPreset(_:)), keyEquivalent: "O")
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(settingSeparator)
        menu.addItem(startAtLogin)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu
    }
    @objc func toggleStartAtLogin(_: Any?) {
        LaunchAtLoginController().setLaunchAtLogin(!LaunchAtLoginController().launchAtLogin, for: NSURL.fileURL(withPath: Bundle.main.bundlePath))
        createMenu()
    }
    @objc func openPreferences(_: Any?) {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [standardConfigPath]
        task.launch()
    }
    
    @objc func openPreset(_: Any?) {
        let dialog = NSOpenPanel()

        dialog.title = "Choose a items.json file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = true
        dialog.canChooseDirectories = false
        dialog.canCreateDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["json"]
        dialog.directoryURL = NSURL.fileURL(withPath: appSupportDirectory, isDirectory: true)

        if dialog.runModal() == .OK, let path = dialog.url?.path {
            if let data = path.data(using: .utf8),
               let jsonString = String(data: data, encoding: .utf8),
               let preset = PresetModel(JSONString: jsonString) {
                coinPriceTouchBarController.reloadJson(coinPairs: preset.coinPairs)
            }
        }
    }

}

