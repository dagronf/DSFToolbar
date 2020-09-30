//
//  PopupMenuViewcontroller.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 30/9/20.
//

import Cocoa
import DSFToolbar

class PopupMenuViewcontroller: NSViewController {

	@IBOutlet var popupMenu: NSMenu!

	var popovercontent = PopoverContentController()

	var toolbarContainer: DSFToolbar?

	override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

		self.build()
    }

	@objc dynamic var popupMenuEnabled = true
	@objc dynamic var popoverViewEnabled = true

	func build() {

		self.toolbarContainer = DSFToolbar.Make(
			toolbarIdentifier: NSToolbar.Identifier("primary-popup"),
			allowsUserCustomization: true
		) {
			DSFToolbar.PopupButton(NSToolbarItem.Identifier("PopupButton"), menu: self.popupMenu)
				.label("Popup")
				.image(ProjectAssets.ImageSet.toolbar_cog.template)
				.bindEnabled(to: self, withKeyPath: "popupMenuEnabled")
				.isSelectable(true)

			DSFToolbar.FixedSpace

			DSFToolbar.PopoverButton(NSToolbarItem.Identifier("Popover View"),
									 popoverContentController: self.popovercontent)
				.label("Popover View")
				.bindEnabled(to: self, withKeyPath: "popoverViewEnabled")

		}
	}

}

extension PopupMenuViewcontroller {
	@IBAction func NewDocument(_ sender: Any) {
		Swift.print("New Document")
	}
	@IBAction func OpenDocument(_ sender: Any) {
		Swift.print("Open Document")
	}
	@IBAction func CloseDocument(_ sender: Any) {
		Swift.print("Close Document")
	}
}

extension PopupMenuViewcontroller: NSMenuItemValidation {
	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		if menuItem.action == #selector(OpenDocument(_:)) {
			return false
		}
		return true
	}
}

extension PopupMenuViewcontroller: DemoContentViewController {
	static func Create() -> NSViewController {
		return PopupMenuViewcontroller()
	}

	static func Title() -> String {
		return "Popup/Popover"
	}

	var customToolbar: DSFToolbar? {
		return self.toolbarContainer
	}

	func cleanup() {
		self.toolbarContainer?.close()
		self.toolbarContainer = nil
	}
}
