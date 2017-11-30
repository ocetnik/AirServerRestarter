//
//  AppDelegate.swift
//  AirServerRestarter
//
//  Created by David Ocetnik on 29/11/2017.
//  Copyright © 2017 David Ocetnik. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let applicationName: String = "AirServer"
    
    let startSelector = #selector(AppDelegate.start)
    let restartSelector = #selector(AppDelegate.restart)
    let quitSelector = #selector(NSApplication.terminate(_:))
    
    let statusItem: NSStatusItem
    
    override init() {
        statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
        
        super.init()
        setupStatusButton()
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return !(
            (menuItem.action == startSelector && getRunningApplication() !== nil) ||
                (menuItem.action == restartSelector && getRunningApplication() == nil)
        )
    }
    
    func delay(_ delay: Double, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func setupStatusButton() {
        if let button = statusItem.button {
            button.image = NSImage(named: "statusBarButtonImage")
        }
    }
    
    func getRunningApplication() -> NSRunningApplication? {
        return NSWorkspace.shared().runningApplications.filter({ $0.localizedName == applicationName }).first
    }
    
    func showModalAlert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func openApplication() {
        guard NSWorkspace.shared().launchApplication(applicationName) else {
            showModalAlert("Could not open application")
            return
        }
    }
    
    @objc func start() {
        self.openApplication()
    }
    
    @objc func restart() {
        guard let runningApplication = getRunningApplication() else {
            showModalAlert("Application is not running")
            return
        }
        
        guard runningApplication.forceTerminate() else {
            showModalAlert("Could not force terminate application")
            return
        }
        
        // TODO refactor without delay (with KVO)
        delay(2) {
            self.openApplication()
        }
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Start AirServer", action: startSelector, keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "Restart AirServer", action: restartSelector, keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit AirServerRestarter", action: quitSelector, keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        constructMenu()
    }
    
}
