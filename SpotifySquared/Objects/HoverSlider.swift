//
//  HoverSlider.swift
//  SpotifySquared
//
//  Created by Tomas Bolger on 10/4/2022.
//

import Cocoa

class HoverSlider: NSSlider {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        wantsLayer = true
        isContinuous = true
        trackFillColor = .white
        controlSize = .mini
    }
    
}
