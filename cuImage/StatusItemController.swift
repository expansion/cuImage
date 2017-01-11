//
//  StatusItemController.swift
//  cuImage
//
//  Created by HuLizhen on 03/01/2017.
//  Copyright © 2017 HuLizhen. All rights reserved.
//

import Cocoa
import MASShortcut

final class StatusItemController: NSObject {
    static let shared = StatusItemController()
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)

    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var uploadImageMenuItem: NSMenuItem!
    @IBOutlet weak var preferencesMenuItem: NSMenuItem!
    @IBOutlet weak var aboutMenuItem: NSMenuItem!
    
    lazy var aboutWindowController: AboutWindowController = AboutWindowController()
    lazy var preferencesWindowController: PreferencesWindowController = PreferencesWindowController()
    
    deinit {
        removeObservers()
    }
    
    private override init() {
        super.init()
        
        setUp()
        addObservers()
    }
    
    private func setUp() {
        guard let nibName = self.className.components(separatedBy: ".").last,
            let nib = NSNib(nibNamed: nibName, bundle: nil),
            nib.instantiate(withOwner: self, topLevelObjects: nil) else {
                assert(false, "Failed to instantiate \(self.className)")
        }
        
        let image = NSImage(named: Constants.statusItemIcon)
        image!.isTemplate = true
        statusItem.image = image
        statusItem.toolTip = Bundle.main.infoDictionary![kIOBundleNameKey] as? String
        statusItem.menu = menu
    }

    @IBAction func handleTappedMenuItem(_ item: NSMenuItem) {
        switch item {
        case uploadImageMenuItem:
            UploadManager.shared.uploadImageOnPasteboard()
        case preferencesMenuItem:
            preferencesWindowController.showWindow(item)
            NSApp.activate(ignoringOtherApps: true)
        case aboutMenuItem:
            aboutWindowController.showWindow(item)
            NSApp.activate(ignoringOtherApps: true)
        default:
            break
        }
    }
    
    private func addObservers() {
        let defaults = UserDefaults.standard
        
        defaults.addObserver(self, forKeyPath: PreferenceKeys.uploadImageShortcut.rawValue,
                             options: [.initial, .new], context: nil)
    }
    
    fileprivate func removeObservers() {
        let defaults = UserDefaults.standard
        defaults.removeObserver(self, forKeyPath: PreferenceKeys.uploadImageShortcut.rawValue)
    }

    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        guard let key = PreferenceKeys(rawValue: keyPath) else { return }
        
        switch key {
        case PreferenceKeys.uploadImageShortcut:
            uploadImageMenuItem.setKeyEquivalent(withShortcut: preferences[.uploadImageShortcut])
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
