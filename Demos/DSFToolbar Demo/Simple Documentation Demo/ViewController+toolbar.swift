//
//  ViewController+toolbar.swift
//  Simple Documentation Demo
//
//  Created by Darren Ford on 9/10/20.
//

import Cocoa

import DSFToolbar

// Uses Fluent System icons
// https://github.com/microsoft/fluentui-system-icons

extension ViewController {
	func makeToolbar() -> DSFToolbar {
		DSFToolbar(
			toolbarIdentifier: NSToolbar.Identifier("Core"),
			allowsUserCustomization: true
		) {
			DSFToolbar.Item(NSToolbarItem.Identifier("item-new"))
				.label("New")
				.isSelectable(true)
				.image(ProjectAssets.ImageSet.toolbar_new_document.template)
				.enabled { [weak self] in
					self?.canAddDocument() ?? false
				}
				.action { [weak self] _ in
					self?.addDocument()
				}

			DSFToolbar.Item(NSToolbarItem.Identifier("item-edit"))
				.label("Edit")
				.isSelectable(true)
				.image(ProjectAssets.ImageSet.toolbar_edit_document.template)
				.enabled { [weak self] in
					self?.canEditDocument() ?? false
				}
				.action { [weak self] _ in
					self?.editDocument()
				}

			DSFToolbar.FlexibleSpace()

			DSFToolbar.Search(NSToolbarItem.Identifier("search-field"))
				.label("Search")
				.isSelectable(true)
				.bindIsEnabled(to: self, withKeyPath: #keyPath(searchEnabled))
				.bindText(self, keyPath: #keyPath(searchText))
		}
	}
}
