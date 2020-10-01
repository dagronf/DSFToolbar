//
//  ViewController.swift
//  Simple Documentation Demo
//
//  Created by Darren Ford on 2/10/20.
//

import Cocoa

import DSFToolbar

// Use Fluent System icons
// https://github.com/microsoft/fluentui-system-icons


class ViewController: NSViewController {

	private var customToolbar: DSFToolbar?

	@objc dynamic var searchEnabled: Bool = true
	@objc dynamic var searchText: String = ""

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.buildToolbar()
	}

	override func viewDidAppear() {
		super.viewDidAppear()
		self.customToolbar?.attachedWindow = self.view.window
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
				allowsUserCustomization: true) {

				DSFToolbar.Image(NSToolbarItem.Identifier("item-new"))
					.label("New")
					.image(ProjectAssets.ImageSet.toolbar_new_document.image)
					.enabled { return false }
					.action { _ in
						Swift.print("Pressed new document")
					}

				DSFToolbar.Image(NSToolbarItem.Identifier("item-edit"))
					.label("Edit")
					.image(ProjectAssets.ImageSet.toolbar_edit_document.image)
					.enabled { return true }
					.action { _ in
						Swift.print("Pressed edit document")
					}

				DSFToolbar.FlexibleSpace

				DSFToolbar.Search(NSToolbarItem.Identifier("search-field"))
					.label("Search")
					.bindEnabled(to: self, withKeyPath: #keyPath(searchEnabled))
					.bindText(self, keyPath: #keyPath(searchText))
			}
	}

}

