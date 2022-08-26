//
//  CustomToolbar.swift
//  DSFToolbar Catalyst Demo
//
//  Created by Darren Ford on 5/10/20.
//

import UIKit

#if targetEnvironment(macCatalyst)

import DSFToolbar
import DSFValueBinders

class ViewControllerToolbar: NSObject {
	func hookToolbar(into scene: UIScene) {
		self.customToolbar.attachedScene = scene
	}

	func unhook() {
		self.customToolbar.close()
		//self.customToolbar.attachedScene = nil
	}

	let boundEnabled = ValueBinder(true)

	let boundSelection = ValueBinder<NSSet>(NSSet(array: [0])) { newValue in
		Swift.print("Styles-alt: New selection is \(newValue)")
	}

	lazy var customToolbar: DSFToolbar = {
		DSFToolbar(
			toolbarIdentifier: NSToolbar.Identifier("primary"),
			allowsUserCustomization: true
		) {
			DSFToolbar.Segmented(
				NSToolbarItem.Identifier("1"),
				selectionMode: .selectOne
			) {
				DSFToolbar.Segmented.Segment()
					.label("section1")
					.title("Solver")
				DSFToolbar.Segmented.Segment()
					.label("section2")
					.title("Resistance")
				DSFToolbar.Segmented.Segment()
					.label("section3")
					.title("Settings")
			}
			.label("Type")
			.setState([1])
			.action { selection in
				Swift.print("New selection is \(selection)")
			}

			DSFToolbar.Segmented(
				NSToolbarItem.Identifier("styles"),
				selectionMode: .selectAny
			) {
				DSFToolbar.Segmented.Segment()
					.label("toolbar-bold")
					.title("1")
					//.image(ProjectAssets.ImageSet.toolbar_bold.image)
				DSFToolbar.Segmented.Segment()
					.label("toolbar-italic")
					.title("2")
					//.image(ProjectAssets.ImageSet.toolbar_italic.image)
				DSFToolbar.Segmented.Segment()
					.label("toolbar-underline")
					.title("3")
					//.image(ProjectAssets.ImageSet.toolbar_underline.image)
			}
			.label("Styles")
			.setState([1, 2])
			.action { selection in
				Swift.print("New selection is \(selection)")
			}

			DSFToolbar.FixedSpace()

			DSFToolbar.Segmented(
				NSToolbarItem.Identifier("styles22"),
				selectionMode: .selectAny
			) {
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
			.bindIsEnabled(boundEnabled)
			.bindSelection(boundSelection)

			DSFToolbar.FlexibleSpace()

			DSFToolbar.Item(NSToolbarItem.Identifier("21"))
				.label("first")
				.image(ProjectAssets.ImageSet.toolbar_watermelon.image)
				.action { _ in
					Swift.print("Pressed first")
				}
			DSFToolbar.Item(NSToolbarItem.Identifier("22"))
				.label("second")
				.image(ProjectAssets.ImageSet.toolbar_burger.image)
				.action { _ in
					Swift.print("Pressed second")
				}
		}
	}()
}

#endif
