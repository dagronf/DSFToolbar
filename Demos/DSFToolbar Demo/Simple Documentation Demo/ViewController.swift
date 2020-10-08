//
//  ViewController.swift
//  Simple Documentation Demo
//
//  Created by Darren Ford on 2/10/20.
//

import Cocoa

import DSFToolbar

class ViewController: NSViewController {

	@objc dynamic var searchEnabled: Bool = true
	@objc dynamic var searchText: String = "finding..." {
		didSet {
			Swift.print("Search text is now '\(searchText)'")
		}
	}

	// A simple helper class to tell us when the window is going away.
	private let windowCloseNotifier = WindowCloseNotifier()

	// Our custom toolbar
	lazy var customToolbar: DSFToolbar = {
		makeToolbar()
	}()

	override func viewDidAppear() {
		super.viewDidAppear()

		// Hook up the toolbar
		self.customToolbar.attachedWindow = self.view.window

		// When the window goes away, close the toolbar object
		self.windowCloseNotifier.observe(self.view.window!) { [weak self] in

			// Need to call close on the toolbar to make sure that any bindings and controls have been released
			self?.customToolbar.close()
		}
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
}

extension ViewController {

	// MARK: Add document

	func canAddDocument() -> Bool {
		return false
	}

	func addDocument() {
		Swift.print("Creating new document...")
	}

	// MARK: Edit document

	func canEditDocument() -> Bool {
		return true
	}

	func editDocument() {
		Swift.print("Editing document...")
	}
}
