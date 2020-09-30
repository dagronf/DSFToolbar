//
//  PopupMenuViewcontroller.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 30/9/20.
//

import Cocoa
import DSFToolbar

class CustomViewController: NSViewController {

	var customContent1 = CustomToolbarItemViewController()
	var customContent2 = CustomToolbarItemViewController()

	@objc dynamic var customContent1Enabled = true

	var toolbarContainer: DSFToolbar?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.

		self.build()
	}

	func build() {

		self.toolbarContainer = DSFToolbar.Make(
			toolbarIdentifier: NSToolbar.Identifier("primary-custom-view"),
			allowsUserCustomization: true
		) {
			DSFToolbar.View(NSToolbarItem.Identifier("customview1"), viewController: self.customContent1)
				.label("Input Levels")
				.bindEnabled(to: self, withKeyPath: "customContent1Enabled")

			DSFToolbar.View(NSToolbarItem.Identifier("customview2"), viewController: self.customContent2)
				.label("Aux Levels")
		}
	}
}

extension CustomViewController: DemoContentViewController {
	static func Create() -> NSViewController {
		return CustomViewController()
	}

	static func Title() -> String {
		return "Custom View"
	}

	var customToolbar: DSFToolbar? {
		return self.toolbarContainer
	}

	func cleanup() {
		self.toolbarContainer?.close()
		self.toolbarContainer = nil
	}
}
