//
//  ImagesViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 29/9/20.
//

import Cocoa

import DSFToolbar
import DSFValueBinders

class ImagesViewController: NSViewController {
	var toolbarContainer: DSFToolbar?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do view setup here.
		self.build()
	}

	// Use dynamic binding so we can set via interface builder

	@objc dynamic var toolbar_watermelon_enabled: Bool = false
	@objc dynamic var toolbar_group_enabled: Bool = true
	@objc dynamic var toolbar_burger_label: String = "Burger"
	@objc dynamic var selectedToolbarItem: String = "Toolbar Selection: (none)"

	func build() {

		self.toolbarContainer = DSFToolbar(
			toolbarIdentifier: "primary-images",
			allowsUserCustomization: true
		) {
			DSFToolbar.Item(NSToolbarItem.Identifier("toolbar-egg"))
				.label("Egg")
				.tooltip("This is the egg")
				.image(ProjectAssets.ImageSet.toolbar_egg.image)
				.isSelectable(true)
				.legacySizes(minSize: NSSize(width: 32, height: 32))
				.action { _ in
					Swift.print("Got egg!")
				}

			DSFToolbar.Item(NSToolbarItem.Identifier("toolbar-watermelon"))
				.label("Watermelon")
				.tooltip("My cat likes watermelon")
				.image(ProjectAssets.ImageSet.toolbar_watermelon.image)
				.isSelectable(true)
				.bindIsEnabled(try! KeyPathBinder(self, keyPath: \.toolbar_watermelon_enabled))
				.legacySizes(minSize: NSSize(width: 32, height: 32))
				.action { _ in
					Swift.print("Got watermelon!")
				}

			DSFToolbar.Item(NSToolbarItem.Identifier("toolbar-burger"))
				.bindLabel(try! KeyPathBinder(self, keyPath: \.toolbar_burger_label))
				.tooltip("I really really want a burger")
				.image(ProjectAssets.ImageSet.toolbar_burger.image)
				.isSelectable(true)
				.legacySizes(minSize: NSSize(width: 32, height: 32))
				.action { _ in
					Swift.print("Got burger!")
				}

			DSFToolbar.FixedSpace()

			// A group of image items

			DSFToolbar.Group(NSToolbarItem.Identifier("food-grouped"), selectionMode: .selectAny) {
				DSFToolbar.Item(NSToolbarItem.Identifier("toolbar-egg-2"))
					.label("Egg")
					.image(ProjectAssets.ImageSet.toolbar_egg.image)
					.legacySizes(minSize: NSSize(width: 32, height: 32))
					.action { _ in
						Swift.print("Got grouped egg!")
					}
				
				DSFToolbar.Item(NSToolbarItem.Identifier("toolbar-watermelon-2"))
					.label("Watermelon")
					.image(ProjectAssets.ImageSet.toolbar_watermelon.image)
					.legacySizes(minSize: NSSize(width: 32, height: 32))
					.action { _ in
						Swift.print("Got grouped watermelon!")
					}
				
				DSFToolbar.Item(NSToolbarItem.Identifier("toolbar-burger-2"))
					.label("Burger")
					.image(ProjectAssets.ImageSet.toolbar_burger.image)
					.legacySizes(minSize: NSSize(width: 32, height: 32))
					.action { _ in
						Swift.print("Got grouped burger!")
					}
			}
			.label("Grouped Foods")
			.legacySizes(minSize: NSSize(width: 96, height: 32))
			.isSelectable(true)
			.bindIsEnabled(try! KeyPathBinder(self, keyPath: \.toolbar_group_enabled))

			/// A bordered button (10.15+ only)

			DSFToolbar.Item(NSToolbarItem.Identifier("toolbar-image-bordered"))
				.label("Boxed Burger")
				.tooltip("My burger is in a box!")
				.image(ProjectAssets.ImageSet.toolbar_burger.image)
				.isSelectable(true)
				.isBordered(true)
				.legacySizes(minSize: NSSize(width: 32, height: 32))
				.action { _ in
					Swift.print("Got bordered burger!")
				}

		}
		.onSelectionChange { newToolbarSelection in
			let msg = "Toolbar Selection: \(newToolbarSelection?.rawValue ?? "(none)")"
			self.selectedToolbarItem = msg
		}
	}
}

extension ImagesViewController: DemoContentViewController {
	static func Create() -> NSViewController {
		return ImagesViewController()
	}

	static func Title() -> String {
		return "Items"
	}

	var customToolbar: DSFToolbar? {
		return self.toolbarContainer
	}

	func cleanup() {
		self.toolbarContainer?.close()
		self.toolbarContainer = nil
	}
}
