//
//  AppDelegate.swift
//  BinancePriceBar
//
//  Created by Hai Pham on 3/8/21.
//

import Cocoa
import ObjectMapper

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    private let btcCharacter = "₿"
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    private let coinPriceTouchBarController = CoinPriceTouchBarController(coinPairs: AppSettings.coinPairs.filter({ $0.enable }))
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
        let customTouchBarItem = NSCustomTouchBarItem(identifier: NSTouchBarItem.Identifier(rawValue: btcCharacter))
        let customTouchBarItemButton = NSButton(title: btcCharacter, target: self, action: #selector(self.customTouchBarItemTapped))
        customTouchBarItem.view = customTouchBarItemButton
        NSTouchBarItem.addSystemTrayItem(customTouchBarItem)
        DFRElementSetControlStripPresenceForIdentifier(NSTouchBarItem.Identifier(rawValue: customTouchBarItem.identifier.rawValue), true)
        
        window = NSWindow(contentViewController: coinPriceTouchBarController)
        window.makeKeyAndOrderFront(nil)
        
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("ic_status_bar"))
        }
        AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true] as NSDictionary)
        createMenu()
    }
    
    @objc private func customTouchBarItemTapped() {
        NSTouchBar.presentSystemModalTouchBar(coinPriceTouchBarController.touchBar, systemTrayItemIdentifier: NSTouchBarItem.Identifier(rawValue: btcCharacter))
    }
    
    func reloadStandardConfig() {
        coinPriceTouchBarController.reloadCoinPairs(coinPairs: AppSettings.coinPairs.filter({ $0.enable }))
    }
    
    func createMenu() {
        let menu = NSMenu()
        
        let startAtLogin = NSMenuItem(title: "Start at login", action: #selector(toggleStartAtLogin(_:)), keyEquivalent: "L")
        startAtLogin.state = LaunchAtLoginController().launchAtLogin ? .on : .off
        
        let showEsc = NSMenuItem(title: "Show Esc", action: #selector(toggleShowEsc), keyEquivalent: "E")
        showEsc.state = AppSettings.showEsc ? .on : .off
        
        let checkForUpdate = NSMenuItem(title: "Check for Update...", action: nil, keyEquivalent: "U")
        checkForUpdate.isEnabled = false
        let supportCoffee = NSMenuItem(title: "Support the project ☕️", action: #selector(donate), keyEquivalent: "S")
        
        menu.addItem(withTitle: "Preferences", action: #selector(openPreferences(_:)), keyEquivalent: ",")
        menu.addItem(withTitle: "Reload Touchbar", action: #selector(reloadTouchBar), keyEquivalent: "R")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(startAtLogin)
        menu.addItem(showEsc)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(checkForUpdate)
        menu.addItem(supportCoffee)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu
    }
    @objc func toggleStartAtLogin(_: Any?) {
        LaunchAtLoginController().setLaunchAtLogin(!LaunchAtLoginController().launchAtLogin, for: NSURL.fileURL(withPath: Bundle.main.bundlePath))
        createMenu()
    }
    @objc func toggleShowEsc() {
        AppSettings.showEsc.toggle()
        coinPriceTouchBarController.reloadTouchBar()
        createMenu()
    }
    @objc func reloadTouchBar() {
        self.reloadStandardConfig()
    }
    @objc func openPreferences(_: Any?) {
        let wc = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "PreferencesWC")
            as? PreferencesWindowController
        wc?.showWindow(self)
    }

    @objc func donate() {
        let url = URL(string: "https://github.com/phhai1710/BinancePriceBar#sparkling_heart-support-the-project")!
        NSWorkspace.shared.open(url)
    }
}

