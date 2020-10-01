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

	private var customToolbar: DSFToolbar?

	@objc dynamic var searchEnabled: Bool = true
	@objc dynamic var searchText: String = ""

	private func windowWillClose() {
		// Need to call close on the toolbar to make sure that any bindings and controls have been release
		self.customToolbar?.close()
	}

	override func viewDidAppear() {
		super.viewDidAppear()

		// Do any additional setup after loading the view.
		self.buildToolbar()

		self.windowCloseNotifier.observe(self.view.window!) { [weak self] in
			self?.windowWillClose()
		}
	}

	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}

	private func buildToolbar() {
		self.customToolbar =
			DSFToolbar.Make(
				toolbarIdentifier: NSToolbar.Identifier("Core"),
				allowsUserCustomization: true
			) {
				DSFToolbar.Image(NSToolbarItem.Identifier("item-new"))
					.label("New")
					.image(ProjectAssets.ImageSet.toolbar_new_document.template)
					.enabled {
						self.canAddDocument()
					}
					.action { _ in
						self.addDocument()
					}

				DSFToolbar.Image(NSToolbarItem.Identifier("item-edit"))
					.label("Edit")
					.image(ProjectAssets.ImageSet.toolbar_edit_document.template)
					.enabled {
						self.canEditDocument()
					}
					.action { _ in
						self.editDocument()
					}

				DSFToolbar.FlexibleSpace

				DSFToolbar.Search(NSToolbarItem.Identifier("search-field"))
					.label("Search")
					.bindEnabled(to: self, withKeyPath: #keyPath(searchEnabled))
					.bindText(self, keyPath: #keyPath(searchText))
			}

		self.customToolbar?.attachedWindow = self.view.window
	}

	// MARK: Add document

	private func canAddDocument() -> Bool {
		return false
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
