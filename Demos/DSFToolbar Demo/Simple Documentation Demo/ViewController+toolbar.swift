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
				.bindLabel(itemName)
				.image(ProjectAssets.ImageSet.toolbar_new_document.template)
				.shouldEnable { [weak self] in
					self?.canAddDocument() ?? false
				}
				.action { [weak self] _ in
					self?.addDocument()
				}

//			DSFToolbar.Button(NSToolbarItem.Identifier("item-edit"), buttonType: .toggle)
//				.label("Edit")
//				.image(NSImage(systemSymbolName: "memorychip", accessibilityDescription: nil)!) // ProjectAssets.ImageSet.toolbar_edit_document.template)
////				.shouldEnable { [weak self] in
////					self?.canEditDocument() ?? false
////				}
//				.action { [weak self] button in
//					if button.state == .on {
//						self?.editDocument()
//					}
//					else {
//						Swift.print("Ended editing")
//					}
//				}

			DSFToolbar.Item(NSToolbarItem.Identifier("item-edit"))
				.label("Edit")
				.image(ProjectAssets.ImageSet.toolbar_edit_document.template)
				.shouldEnable { [weak self] in
					self?.canEditDocument() ?? false
				}
				.action { [weak self] _ in
					self?.editDocument()
				}

			DSFToolbar.FixedSpace()

			DSFToolbar.Segmented(
					NSToolbarItem.Identifier("view-mode"),
					type: .Grouped,
					switching: .selectOne)
			{
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_view_regular.template)
					.tooltip("Print View")
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_view_outline.template)
					.tooltip("Outline View")
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_view_data.template)
					.tooltip("Data View")
			}
			.label("View")
			.bindSelection(viewModeSelection)

			DSFToolbar.FlexibleSpace()

			DSFToolbar.Button("search-active", buttonType: .onOff)
				.image(ProjectAssets.ImageSet.toolbar_view_data.template)
				.alternateImage(ProjectAssets.ImageSet.toolbar_view_outline.template)
				.bindOnOffState(searchEnabled)

			DSFToolbar.Search("search-field")
				.label("Search noodle")
				.placeholderText("Search for stuff…")
				.isSelectable(true)
				.bindIsEnabled(searchEnabled)
				.bindSearchText(searchText)
				.onSearchTextChange { _, val in
					Swift.print("onSearchTextChange: \(val)")
				}
		}
	}
}
