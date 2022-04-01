//
//  WindowDragView.swift
//  MusicWidget
//
//  Created by Tomas Bolger on 29/3/2022.
//

import Cocoa

class WindowDragView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
    }
    
    override public func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
        print("Mouse down")
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        print("Mouse entered")
    }
    
}
