//
//  TitlebarPropertiesWindowController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 1/10/20.
//

import Cocoa

struct WindowSettings {
	var titlebarVisibility: Bool = true
	var titlebarTransparent: Bool = false

	var unifiedTitlebar: Bool = false
	var fullsizeContentView: Bool = false
}

class TitlebarPropertiesWindowController: NSWindowController {

	override var windowNibName: NSNib.Name? {
		NSNib.Name("TitlebarPropertiesWindowController")
	}

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

	////

	var updateSettings: ((WindowSettings) -> Void)?

	@objc dynamic var titleVisibility: Bool = true {
		didSet {
			self.updateSettings(self)
		}
	}
	@objc dynamic var titlebarTransparent: Bool = false {
		didSet {
			self.updateSettings(self)
		}
	}
	@objc dynamic var unifiedTitlebar: Bool = false {
		didSet {
			self.updateSettings(self)
		}
	}
	@objc dynamic var fullsizeContentView: Bool = false {
		didSet {
			self.updateSettings(self)
		}
	}


	@IBAction func updateSettings(_ sender: Any) {
		let w = WindowSettings(
			titlebarVisibility: self.titleVisibility,
			titlebarTransparent: self.titlebarTransparent,
			unifiedTitlebar: self.unifiedTitlebar,
			fullsizeContentView: fullsizeContentView
		)

		self.updateSettings?(w)
	}

    
}
