//
//  AppDelegate.swift
//  SpotifySquared
//
//  Created by Tomas Bolger on 27/3/2022.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let popover = NSPopover()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        if let button = statusItem.button {
            button.action = #selector(togglePopover(_:))
        }
        // popover.contentViewController = ViewController.freshController()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func togglePopover(_ sender: Any?) {
//      if popover.isShown {
//        closePopover(sender: sender)
//      } else {
//        showPopover(sender: sender)
//      }
    }

    func showPopover(sender: Any?) {
      if let button = statusItem.button {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      }
    }

    func closePopover(sender: Any?) {
      popover.performClose(sender)
    }
    
}

