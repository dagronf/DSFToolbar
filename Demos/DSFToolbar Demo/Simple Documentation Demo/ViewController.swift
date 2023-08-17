//
//  ViewController.swift
//  Simple Documentation Demo
//
//  Created by Darren Ford on 2/10/20.
//

import Cocoa

import DSFToolbar
import DSFValueBinders

class ViewController: NSViewController {

	let viewModeSelection = ValueBinder<NSSet>(NSSet()) { newValue in
		Swift.print("View mode is now \(newValue)")
	}

	let itemName = ValueBinder<String>("New") { newValue in
		Swift.print("Item name is now \(newValue)")
	}

	let searchEnabled = ValueBinder(true) { newValue in
		Swift.print("Search enabled is now \(newValue)")
	}

	let searchText = ValueBinder("") { newValue in
		Swift.print("Search text is now \(newValue)")
	}

	// A simple helper class to tell us when the window is going away.
	private let windowCloseNotifier = WindowCloseNotifier()

	// Our custom toolbar
	lazy var customToolbar: DSFToolbar = {
		makeToolbar()
	}()

	let displayMode = ValueBinder<NSToolbar.DisplayMode>(.iconAndLabel)

	override func viewDidAppear() {
		super.viewDidAppear()

		// Hook up the toolbar
		self.customToolbar.attachedWindow = self.view.window

		// Set our view selection to the second group item
		self.viewModeSelection.wrappedValue = NSSet(array: [1])

		// When the window goes away, close the toolbar object
		self.windowCloseNotifier.observe(self.view.window!) { [weak self] in

			// Need to call close on the toolbar to make sure that any bindings and controls have been released
			self?.customToolbar.close()
		}

		// Set the display mode so that the icon and label are presented by default
		self.customToolbar.displayMode(.iconAndLabel)
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
