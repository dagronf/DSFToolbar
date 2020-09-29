//
//  PropertiesViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 29/9/20.
//

import Cocoa

import DSFToolbar

class PropertiesViewController: NSViewController {

	@IBOutlet var primarySplit: NSSplitView!

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

			self.view.addSubview(c.view)
			c.view.frame = self.view.bounds

			//self.view.window?.makeFirstResponder(c)

			self.view.addConstraints(
				NSLayoutConstraint.constraints(
					withVisualFormat: "V:|[item]|",
					options: .alignAllCenterX,
					metrics: nil, views: ["item": c.view]))
			self.view.addConstraints(
				NSLayoutConstraint.constraints(
					withVisualFormat: "H:|[item]|",
					options: .alignAllCenterY,
					metrics: nil, views: ["item": c.view]))
		}

		// Attach the custom toolbar to the window
		if let c = self.current as? DemoContentViewController {
			c.customToolbar?.attachedWindow = self.view.window
		}

		// And close the previous one
		if let p = self.previous as? DemoContentViewController {
			p.cleanup()
			self.previous = nil
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
