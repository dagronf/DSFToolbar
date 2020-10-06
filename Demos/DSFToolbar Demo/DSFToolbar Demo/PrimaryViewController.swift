//
//  PrimaryViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 29/9/20.
//

import Cocoa

import DSFToolbar_beta

class PrimaryViewController: NSViewController {
	@IBOutlet var scrollView: NSScrollView!

	@IBOutlet var propertiesViewController: PropertiesViewController!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do view setup here.
		scrollView.automaticallyAdjustsContentInsets = true

		// Enable the toolbar style picker for macOS11
		if #available(macOS 11, *) {
			self.toolbarStyleEnabled = true
		}
	}

	private var intern: Bool = false

	@objc dynamic var titleVisibility: Bool = true {
		didSet {
			if !intern {
				intern = true
				let ms = titleSelection.mutableCopy() as! NSMutableIndexSet
				self.titleVisibility ? ms.add(0) : ms.remove(0)
				self.titleSelection = ms
				self.updateSettings()
				intern = false
			}
		}
	}

	@objc dynamic var titlebarTransparent: Bool = false {
		didSet {
			if !intern {
				intern = true
				let ms = titleSelection.mutableCopy() as! NSMutableIndexSet
				self.titlebarTransparent ? ms.add(1) : ms.remove(1)
				self.titleSelection = ms
				self.updateSettings()
				intern = false
			}
		}
	}

	@objc dynamic var titleSelection = NSIndexSet(index: 1) {
		didSet {
			self.titleVisibility = self.titleSelection.contains(0)
			self.titlebarTransparent = self.titleSelection.contains(1)
		}
	}

	@objc dynamic var fullsizeContentView: Bool = false {
		didSet {
			self.updateSettings()
		}
	}

	@objc dynamic var toolbarStyleEnabled: Bool = false

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

		if #available(macOS 11, *) {
			w.toolbarStyle = .expanded
		}

		self.propertiesViewController.updateOffsets()
	}

	@IBAction func toolbarStyleAutomatic(_ sender: NSMenuItem) {
		if #available(macOS 11, *) {
			guard let w = self.view.window else { return }

			switch sender.tag {
			case 0:
				w.toolbarStyle = .automatic
			case 1:
				w.toolbarStyle = .expanded
			case 2:
				w.toolbarStyle = .preference
			case 3:
				w.toolbarStyle = .unified
			case 4:
				w.toolbarStyle = .unifiedCompact
			default:
				fatalError()
			}
		}
	}
}
