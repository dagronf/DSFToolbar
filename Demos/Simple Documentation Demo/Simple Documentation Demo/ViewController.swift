//
//  ViewController.swift
//  Simple Documentation Demo
//
//  Created by Darren Ford on 2/10/20.
//

import Cocoa

import DSFToolbar

// Uses Fluent System icons
// https://github.com/microsoft/fluentui-system-icons

class ViewController: NSViewController {
	private let windowCloseNotifier = WindowCloseNotifier()

	@objc dynamic var searchEnabled: Bool = true
	@objc dynamic var searchText: String = "finding..." {
		didSet {
			Swift.print("Search text is now '\(searchText)'")
		}
	}

	private func windowWillClose() {
		// Need to call close on the toolbar to make sure that any bindings and controls have been release
		self.customToolbar.close()
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		// Do any additional setup after loading the view.

		// Hook up the toolbar
		self.customToolbar.attachedWindow = self.view.window

		self.windowCloseNotifier.observe(self.view.window!) { [weak self] in
			self?.windowWillClose()
		}
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}

	// Custom toolbar
	lazy var customToolbar: DSFToolbar = {
		DSFToolbar.Make(
			toolbarIdentifier: NSToolbar.Identifier("Core"),
			allowsUserCustomization: true) {

			DSFToolbar.Item(NSToolbarItem.Identifier("item-new"))
				.label("New")
				.isSelectable(true)
				.image(ProjectAssets.ImageSet.toolbar_new_document.template)
				.enabled {
					self.canAddDocument()
				}
				.action { _ in
					self.addDocument()
				}

			DSFToolbar.Item(NSToolbarItem.Identifier("item-edit"))
				.label("Edit")
				.isSelectable(true)
				.image(ProjectAssets.ImageSet.toolbar_edit_document.template)
				.enabled {
					self.canEditDocument()
				}
				.action { _ in
					self.editDocument()
				}

			DSFToolbar.FlexibleSpace()

			DSFToolbar.Search(NSToolbarItem.Identifier("search-field"))
				.label("Search")
				.isSelectable(true)
				.bindIsEnabled(to: self, withKeyPath: #keyPath(searchEnabled))
				.bindText(self, keyPath: #keyPath(searchText))
		}
	}()

	// MARK: Add document

	private func canAddDocument() -> Bool {
		return true
	}

	private func addDocument() {
		Swift.print("Creating new document...")
	}

	// MARK: Edit document

	private func canEditDocument() -> Bool {
		return true
	}

	private func editDocument() {
		Swift.print("Editing document...")
	}
}
