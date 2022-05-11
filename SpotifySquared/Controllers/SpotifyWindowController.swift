//
//  SpotifyWindowController.swift
//  SpotifySquared
//
//  Created by Tomas Bolger on 29/3/2022.
//

import Cocoa

class SpotifyWindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.configureWindowAppearance()
        self.configureWindowBehaviour()
    }
    
    func configureWindowBehaviour() {
        if let window = window {
            window.isMovableByWindowBackground = true
            window.isMovable = true
            window.level = .floating
        }
    }
    
    func configureWindowAppearance() {
        if let window = window {
            window.setFrame(NSRect(x: 0, y: 0, width: 250, height: 250), display: true)
            window.isOpaque = false
            window.backgroundColor = NSColor.clear
            if let view = window.contentView {
                view.wantsLayer = true
                view.layer?.backgroundColor = NSColor.darkGray.cgColor
                view.layer?.cornerRadius = 10
                view.layer?.borderColor = CGColor(gray: 1, alpha: 0.7)
                view.layer?.borderWidth = 0.25
            }
            
        }
    }
    
}
