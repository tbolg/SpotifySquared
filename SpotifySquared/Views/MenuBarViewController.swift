//
//  MenuBarViewController.swift
//  SpotifySquared
//
//  Created by Tomas Bolger on 10/4/2022.
//

import Cocoa

class MenuBarViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension MenuBarViewController {
  // MARK: Storyboard instantiation
  static func freshController() -> MenuBarViewController {
    //1.
      let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    //2.
      let identifier = NSStoryboard.SceneIdentifier("MenuBarViewController")
    //3.
    guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? MenuBarViewController else {
      fatalError("Can't find MenuBarViewController. Check Main.storyboard")
    }
    return viewcontroller
  }
}
