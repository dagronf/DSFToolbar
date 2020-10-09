//
//  ViewController.swift
//  Simple Documentation Demo
//
//  Created by Darren Ford on 2/10/20.
//

import Cocoa

import DSFToolbar

class Binding<TARGET, VALUE> where TARGET: NSObject {
	weak var object: TARGET? = nil
	var keyPath: ReferenceWritableKeyPath<TARGET, VALUE>

	init(o: TARGET, k: ReferenceWritableKeyPath<TARGET, VALUE>) {
		self.object = o
		self.keyPath = k
	}

	func update(_ value: VALUE) {
		if let o = object {
			o[keyPath: self.keyPath] = value
		}
	}

}

class ViewController: NSViewController {

	@objc dynamic var viewModeSelection = NSSet() {
		didSet {
			Swift.print("View mode is now \(viewModeSelection)")
		}
	}

	@objc dynamic var itemName: String = "New"

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

	func bind<T>(object: NSObject, keyPath: ReferenceWritableKeyPath<T, Bool>) {
		let str = NSExpression(forKeyPath: keyPath).keyPath
		object.addObserver(self, forKeyPath: str,
						   options: [.new],
						   context: nil)

	}

	override func viewDidAppear() {
		super.viewDidAppear()


		self.bind(object: self, keyPath: \ViewController.searchEnabled)

//		var ttt = Binding<ViewController, Bool>()
//
//		let o = self
//		let e = \ViewController.searchEnabled
//
//		o[keyPath: e] = false



		// Hook up the toolbar
		self.customToolbar.attachedWindow = self.view.window

		// Set our view selection to the second group item
		self.viewModeSelection = NSSet(array: [1])

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
