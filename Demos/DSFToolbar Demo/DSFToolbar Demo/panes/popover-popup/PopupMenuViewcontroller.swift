//
//  PopupMenuViewcontroller.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 30/9/20.
//

import Cocoa
import DSFToolbar_beta

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

	lazy var colorButton: NSButton? = {
		let b = ColorDropdownButton()
		b.translatesAutoresizingMaskIntoConstraints = false
		b.addConstraint(NSLayoutConstraint(item: b, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48))
		//b.addConstraint(NSLayoutConstraint(item: b, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 23))
		return b
	}()

	/// Store the popoverItem so that we can get to it easily
	lazy var popoverViewItem: DSFToolbar.PopoverButton = {
		DSFToolbar.PopoverButton(NSToolbarItem.Identifier("Popover View"),
								 button: self.colorButton,
								 popoverContentController: self.popovercontent)
			.label("Color")
			.image(ProjectAssets.ImageSet.toolbar_cog.template)
			.legacySizes(minSize: NSSize(width: 48, height: 30))
			.bindIsEnabled(to: self, withKeyPath: \PopupMenuViewcontroller.popoverViewEnabled)
	}()

	func build() {
		self.popovercontent.colorChange = { [weak self] color in
			// Make sure that we weakly capture self, or else we memory leak
			guard let `self` = self else { return }
			if let b = self.popoverViewItem.button as? ColorDropdownButton {
				b.selectedColor = color
			}
		}
		
		self.toolbarContainer = DSFToolbar(
			toolbarIdentifier: NSToolbar.Identifier("primary-popup"),
			allowsUserCustomization: true
		) {
			DSFToolbar.PopupButton(NSToolbarItem.Identifier("PopupButton"), menu: self.popupMenu)
				.label("Popup")
				.image(ProjectAssets.ImageSet.toolbar_cog.template)
				.bindIsEnabled(to: self, withKeyPath: \PopupMenuViewcontroller.popupMenuEnabled)
				.legacySizes(minSize: NSSize(width: 48, height: 32))
				.isSelectable(true)
			
			DSFToolbar.FixedSpace()
			
			self.popoverViewItem
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

class WindowKeyChangeNotifier {

	weak var window: NSWindow!
	var become: NSObjectProtocol?
	var resign: NSObjectProtocol?

	init(_ window: NSWindow, _ block: @escaping (Bool) -> Void) {
		self.become = NotificationCenter.default.addObserver(
			forName: NSWindow.didBecomeKeyNotification, object: window,
			queue: OperationQueue.main) { _ in
			block(true)
		}

		self.resign = NotificationCenter.default.addObserver(
			forName: NSWindow.didResignKeyNotification, object: window,
			queue: OperationQueue.main) { _ in
			block(false)
		}
	}

	deinit {
		self.become = nil
		self.resign = nil
	}
}
