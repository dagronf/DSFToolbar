//
//  SegmentedViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 29/9/20.
//

import Cocoa

import DSFToolbar

class SegmentedViewController: NSViewController {

	var toolbarContainer: DSFToolbar?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.

		self.build()
	}

	func build() {

		self.toolbarContainer = DSFToolbar.Make(
			toolbarIdentifier: NSToolbar.Identifier("primary-segmented"),
			allowsUserCustomization: true) {

			DSFToolbar.Segmented(
				NSToolbarItem.Identifier("toolbar-styles-2"),
				type: .Separated,
				switching: .selectAny,
				segmentWidths: 32,
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_bold.template, scaling: .scaleProportionallyDown),
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_italic.template, scaling: .scaleProportionallyDown),
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_underline.template, scaling: .scaleProportionallyDown)
			)
			.label("Styles Separated")
			.action { (selection) in
				Swift.print("Styles Separated: New Selection -> \(selection)")
			}

			DSFToolbar.Segmented(
				NSToolbarItem.Identifier("toolbar-styles"),
				type: .Grouped,
				switching: .selectAny,
				segmentWidths: 32,
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_bold.template, scaling: .scaleProportionallyDown),
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_italic.template, scaling: .scaleProportionallyDown),
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_underline.template, scaling: .scaleProportionallyDown)
			)
			.label("Styles Grouped")
			.action { (selection) in
				Swift.print("Styles Grouped: New Selection -> \(selection)")
			}

			DSFToolbar.Segmented(
				NSToolbarItem.Identifier("toolbar-styles-3"),
				type: .Separated,
				switching: .selectOne,
				segmentWidths: 32,
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_left.template, scaling: .scaleProportionallyDown),
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_centre.template, scaling: .scaleProportionallyDown),
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_right.template, scaling: .scaleProportionallyDown),
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_full.template, scaling: .scaleProportionallyDown)
			)
			.label("Justify Separate")
			.action { (selection) in
				Swift.print("Justify Separate: New Selection -> \(selection)")
			}

			DSFToolbar.Segmented(
				NSToolbarItem.Identifier("toolbar-styles-4"),
				type: .Grouped,
				switching: .selectOne,
				segmentWidths: 32,
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_left.template, scaling: .scaleProportionallyDown),
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_centre.template, scaling: .scaleProportionallyDown),
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_right.template, scaling: .scaleProportionallyDown),
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_full.template, scaling: .scaleProportionallyDown)
			)
			.label("Justify Grouped")
			.action { (selection) in
				Swift.print("Justify Grouped: New Selection -> \(selection)")
			}
		}
	}
}

extension SegmentedViewController: DemoContentViewController {
	static func Create() -> NSViewController {
		return SegmentedViewController()
	}

	static func Title() -> String {
		return "Segmented"
	}

	var customToolbar: DSFToolbar? {
		return self.toolbarContainer
	}

	func cleanup() {
		self.toolbarContainer?.close()
		self.toolbarContainer = nil
	}
}
