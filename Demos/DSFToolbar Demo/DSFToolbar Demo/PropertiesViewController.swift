//
//  PropertiesViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 29/9/20.
//

import Cocoa

import DSFToolbar
import DSFValueBinders

class PropertiesViewController: NSViewController {

	@IBOutlet var primarySplit: NSSplitView!

	@IBOutlet weak var primaryViewController: PrimaryViewController!

	@IBOutlet weak var contentView: NSView!
	@IBOutlet weak var contentTopConstraint: NSLayoutConstraint!

	var previous: NSViewController? = nil
	var current: NSViewController? = nil {
		willSet {
			self.previous = self.current
		}
		didSet {
			self.configureForNewController()
		}
	}

	private func configureForNewController() {
		if let prev = self.previous {
			prev.view.removeFromSuperview()
		}

		if let c = self.current {

			if let c = self.current as? SeparatorViewController {
				c.primarySplit = self.primarySplit
			}

			self.contentView.addSubview(c.view)
			c.view.frame = self.contentView.bounds

			//self.view.window?.makeFirstResponder(c)

			self.contentView.addConstraints(
				NSLayoutConstraint.constraints(
					withVisualFormat: "V:|[item]|",
					options: .alignAllCenterX,
					metrics: nil, views: ["item": c.view]))
			self.contentView.addConstraints(
				NSLayoutConstraint.constraints(
					withVisualFormat: "H:|[item]|",
					options: .alignAllCenterY,
					metrics: nil, views: ["item": c.view]))
		}

		// Attach the custom toolbar to the window
		if let c = self.current as? DemoContentViewController {
			c.customToolbar?.attachedWindow = self.view.window
			c.customToolbar?.onSizeModeChange { newMode in
				Swift.print("Size mode changed -> \(newMode.rawValue)")
			}
			try! c.customToolbar?.bindDisplayMode(self.primaryViewController.displayModeBinder)
		}

		self.updateOffsets()

		// And close the previous one
		if let p = self.previous as? DemoContentViewController {
			p.cleanup()
			self.previous = nil
		}

		if let c = self.current {
			Swift.print("New controller is -> \(c.self)")
		}
	}

	func updateOffsets() {

		if let c = self.current as? DemoContentViewController {
			c.customToolbar?.attachedWindow = self.view.window
			let cVal = c.customToolbar?.toolbarHeight ?? -1
			let cVal2 = c.customToolbar?.contentOffsetForToolbar ?? -1
			self.primaryViewController?.toolbarHeightMessage =
				"> Toolbar Height: \(cVal)"
			self.primaryViewController?.toolbarOffsetMessage =
				"> Content Offset: \(cVal2)"

			self.contentTopConstraint.animator().constant = cVal2
			self.contentView.needsUpdateConstraints = true
			self.contentView.needsLayout = true
		}
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		// Start with the 'empty selection' view controller
		self.selectedName(name: "empty content")
	}

	override func viewWillDisappear() {
		super.viewWillDisappear()

		if let c = self.current as? DemoContentViewController {
			c.cleanup()
		}
	}

	func selectedName(name: String) {

		let vc: NSViewController =
			DemoContent.controller(for: name) ?? CoreViewController()

		self.current = vc
	}

}
