//
//  SeparatorViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 30/9/20.
//

import Cocoa
import DSFToolbar

class SeparatorViewController: NSViewController {

	var primarySplit: NSSplitView!

	@IBOutlet weak var localSplitView: NSSplitView!


	var toolbarContainer: DSFToolbar?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

		self.build()
    }


	func build() {
		self.toolbarContainer = DSFToolbar(
			toolbarIdentifier: NSToolbar.Identifier("primary-separator"),
			allowsUserCustomization: true
		) {

			DSFToolbar.Item(NSToolbarItem.Identifier("enabler"))
				.image(ProjectAssets.ImageSet.toolbar_burger.image)
				.isBordered(true)
				.legacySizes(minSize: NSSize(width: 32, height: 28))

			DSFToolbar.Separator(
				NSToolbarItem.Identifier("primary-separator-sep22"),
				splitView: self.primarySplit,
				dividerIndex: 0)

			DSFToolbar.Segmented(
				NSToolbarItem.Identifier("primary-separator-styles"),
				type: .Grouped,
				switching: .selectAny,
				segmentWidths: 32) {

				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_bold.template, scaling: .scaleProportionallyDown)
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_italic.template, scaling: .scaleProportionallyDown)
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_underline.template, scaling: .scaleProportionallyDown)
				
			}
			.label("Styles Grouped")
			.legacySizes(minSize: NSSize(width: 105, height: 27))
			.action { (selection) in
				Swift.print("Styles Grouped: New Selection -> \(selection)")
			}

			DSFToolbar.Separator(
				NSToolbarItem.Identifier("primary-separator-sep-local22"),
				splitView: self.localSplitView,
				dividerIndex: 0
			)

			DSFToolbar.Segmented(
				NSToolbarItem.Identifier("primary-separator-justification"),
				type: .Grouped,
				switching: .selectOne,
				segmentWidths: 32,
				segments: DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_left.template, scaling: .scaleProportionallyDown),
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_centre.template, scaling: .scaleProportionallyDown),
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_right.template, scaling: .scaleProportionallyDown),
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_full.template, scaling: .scaleProportionallyDown)
			)
			.label("Justify Grouped")
			.legacySizes(minSize: NSSize(width: 140, height: 27))
			.action { (selection) in
				Swift.print("Justify Grouped: New Selection -> \(selection)")
			}

			DSFToolbar.FlexibleSpace()

			DSFToolbar.Search(NSToolbarItem.Identifier("search-field"))
				.label("Search for stuff")
		}
	}
}


extension SeparatorViewController: DemoContentViewController {
	static func Create() -> NSViewController {
		return SeparatorViewController()
	}

	static func Title() -> String {
		return "Separator"
	}

	var customToolbar: DSFToolbar? {
		return self.toolbarContainer
	}

	func cleanup() {
		self.toolbarContainer?.close()
		self.toolbarContainer = nil
	}
}
