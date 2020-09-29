//
//  CoreViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 30/9/20.
//

import Cocoa

import DSFToolbar

class CoreViewController: NSViewController {
	var demoToolbar: DSFToolbar? = {
		DSFToolbar.Make(toolbarIdentifier: NSToolbar.Identifier("Core")) {
			DSFToolbar.Image(NSToolbarItem.Identifier("core1"))
		}
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}
}

extension CoreViewController: DemoContentViewController {
	static func Create() -> NSViewController {
		return CoreViewController()
	}

	static func Title() -> String {
		return "Core"
	}

	var customToolbar: DSFToolbar? {
		return self.demoToolbar
	}

	func cleanup() {
		self.demoToolbar?.close()
		self.demoToolbar = nil
	}
}
