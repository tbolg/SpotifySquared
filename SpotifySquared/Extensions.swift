//
//  Extensions.swift
//  SpotifySquared
//
//  Created by Tomas Bolger on 2/4/2022.
//

import Cocoa
import Foundation

extension NSAppleScript {
    static func go(code: String, completionHandler: (Bool, NSAppleEventDescriptor?, NSDictionary?) -> Void) {
        var error: NSDictionary?
        let script = NSAppleScript(source: code)
        let output = script?.executeAndReturnError(&error)
        
        if let out = output {
            completionHandler(true, out, nil)
        }
        else {
            completionHandler(false, nil, error)
        }
    }
}
