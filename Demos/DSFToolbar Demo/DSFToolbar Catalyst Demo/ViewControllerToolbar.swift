//
//  CustomToolbar.swift
//  DSFToolbar Catalyst Demo
//
//  Created by Darren Ford on 5/10/20.
//

import UIKit

#if targetEnvironment(macCatalyst)
import DSFToolbar

class ViewControllerToolbar: NSObject {
	func hookToolbar(into scene: UIScene) {
		self.customToolbar.attachedScene = scene
	}

	func unhook() {
		self.customToolbar.close()
		//self.customToolbar.attachedScene = nil
	}

	@objc dynamic var boundEnabled: Bool = true
	@objc dynamic var boundSelection: NSSet = NSSet(array: [1, 2]) {
		didSet {
			Swift.print("Styles-alt: New selection is \(self.boundSelection)")
		}
	}

	lazy var customToolbar: DSFToolbar = {
		DSFToolbar.Make(toolbarIdentifier: NSToolbar.Identifier("primary"),
						allowsUserCustomization: true) {
			DSFToolbar.Segmented(NSToolbarItem.Identifier("1"),
								 selectionMode: .selectOne) {
				DSFToolbar.Segmented.Segment()
					.label("section1").title("Solver")
				DSFToolbar.Segmented.Segment()
					.label("section2").title("Resistance")
				DSFToolbar.Segmented.Segment()
					.label("section3").title("Settings")
			}
			.label("Type")
			.setState([1])
			.action { selection in
				Swift.print("New selection is \(selection)")
			}

			DSFToolbar.Segmented(NSToolbarItem.Identifier("styles"),
								 selectionMode: .selectAny) {
				DSFToolbar.Segmented.Segment()
					.label("toolbar-bold")
					.image(ProjectAssets.ImageSet.toolbar_bold.image)
				DSFToolbar.Segmented.Segment()
					.label("toolbar-italic")
					.image(ProjectAssets.ImageSet.toolbar_italic.image)
				DSFToolbar.Segmented.Segment()
					.label("toolbar-underline")
					.image(ProjectAssets.ImageSet.toolbar_underline.image)
			}
			.label("Styles")
			.setState([1, 2])
			.action { selection in
				Swift.print("New selection is \(selection)")
			}

			DSFToolbar.FixedSpace()

			DSFToolbar.Segmented(NSToolbarItem.Identifier("styles22"),
								 selectionMode: .selectAny) {
				DSFToolbar.Segmented.Segment()
					.label("toolbar-bold-22")
					.image(ProjectAssets.ImageSet.toolbar_bold.image)
				DSFToolbar.Segmented.Segment()
					.label("toolbar-italic-22")
					.image(ProjectAssets.ImageSet.toolbar_italic.image)
				DSFToolbar.Segmented.Segment()
					.label("toolbar-underline-22")
					.image(ProjectAssets.ImageSet.toolbar_underline.image)
			}
			.label("Styles-alt")
			.tooltip("This is the alternate style selector")
			.bindIsEnabled(to: self, withKeyPath: #keyPath(boundEnabled))
			.bindSelection(self, keyPath: #keyPath(boundSelection))

			DSFToolbar.FlexibleSpace()

			DSFToolbar.Image(NSToolbarItem.Identifier("21"))
				.label("first")
				.image(ProjectAssets.ImageSet.toolbar_watermelon.image)
				.action { _ in
					Swift.print("Pressed first")
				}
			DSFToolbar.Image(NSToolbarItem.Identifier("22"))
				.label("second")
				.image(ProjectAssets.ImageSet.toolbar_burger.image)
				.action { _ in
					Swift.print("Pressed second")
				}
		}
	}()
}

#else

class ViewControllerToolbar {
	func hookToolbar(into _: UIScene) {}
	func unhook() {}
}

#endif
