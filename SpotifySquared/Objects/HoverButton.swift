//
//  HoverButton.swift
//  SpotifySquared
//
//  Created by Tomas Bolger on 10/4/2022.
//

import Cocoa

class HoverButton: NSButton {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        self.showsBorderOnlyWhileMouseInside = true
    }
    
}
