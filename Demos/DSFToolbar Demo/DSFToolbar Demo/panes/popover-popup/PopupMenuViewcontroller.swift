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
		self.popovercontent.colorChange = { color in
			if let pv: DSFToolbar.PopoverButton = self.toolbarContainer?.item(identifier: NSToolbarItem.Identifier("Popover View")) {
				let b = pv.button
				b?.wantsLayer = true
				b?.layer?.backgroundColor = color?.cgColor
			}
		}
		
		self.toolbarContainer = DSFToolbar.Make(
			toolbarIdentifier: NSToolbar.Identifier("primary-popup"),
			allowsUserCustomization: true
		) {
			DSFToolbar.PopupButton(NSToolbarItem.Identifier("PopupButton"), menu: self.popupMenu)
				.label("Popup")
				.image(ProjectAssets.ImageSet.toolbar_cog.template)
				.bindEnabled(to: self, withKeyPath: #keyPath(popupMenuEnabled))
				.legacySizes(minSize: NSSize(width: 48, height: 32))
				.isSelectable(true)
			
			DSFToolbar.FixedSpace
			
			DSFToolbar.PopoverButton(NSToolbarItem.Identifier("Popover View"), popoverContentController: self.popovercontent)
				.label("Popover View")
				.image(ProjectAssets.ImageSet.toolbar_cog.template)
				.legacySizes(minSize: NSSize(width: 48, height: 30))
				.bindEnabled(to: self, withKeyPath: #keyPath(popoverViewEnabled))
		}
	}
}

extension PopupMenuViewcontroller {
	@IBAction func NewDocument(_: Any) {
		Swift.print("New Document")
	}
	
	@IBAction func OpenDocument(_: Any) {
		Swift.print("Open Document")
	}
	
	@IBAction func CloseDocument(_: Any) {
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
