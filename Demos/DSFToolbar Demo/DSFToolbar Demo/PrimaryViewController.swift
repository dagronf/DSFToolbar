//
//  PrimaryViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 29/9/20.
//

import Cocoa

import DSFToolbar

class PrimaryViewController: NSViewController {
	@IBOutlet weak var scrollView: NSScrollView!

	@IBOutlet var propertiesViewController: PropertiesViewController!


    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do view setup here.
		scrollView.automaticallyAdjustsContentInsets = true
    }

	@objc dynamic var titleVisibility: Bool = true {
		didSet {
			self.updateSettings()
		}
	}
	@objc dynamic var titlebarTransparent: Bool = false {
		didSet {
			self.updateSettings()
		}
	}

	@objc dynamic var fullsizeContentView: Bool = false {
		didSet {
			self.updateSettings()
		}
	}

	/// Unified toolbar always on since Yosemite
	@objc dynamic var unifiedTitlebarEnabled: Bool = false
	@objc dynamic var unifiedTitlebar: Bool = true

	@objc dynamic var toolbarHeightMessage: String = ""
	@objc dynamic var toolbarOffsetMessage: String = ""

	func updateSettings() {

		guard let w = self.view.window else { return }
		w.titleVisibility = titleVisibility ? .visible : .hidden
		w.titlebarAppearsTransparent = titlebarTransparent

		if unifiedTitlebar {
			w.styleMask.insert(NSWindow.StyleMask.unifiedTitleAndToolbar)
		}
		else {
			w.styleMask.remove(NSWindow.StyleMask.unifiedTitleAndToolbar)
		}

		if fullsizeContentView {
			w.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
		}
		else {
			w.styleMask.remove(NSWindow.StyleMask.fullSizeContentView)
		}

		self.propertiesViewController.updateOffsets()

	}
}
