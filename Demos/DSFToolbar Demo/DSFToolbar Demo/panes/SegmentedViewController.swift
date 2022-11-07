//
//  SegmentedViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 29/9/20.
//

import Cocoa

import DSFToolbar
import DSFValueBinders

class SegmentedViewController: NSViewController {
	var toolbarContainer: DSFToolbar?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.

		self.build()
	}

	// This is also set within IB, so it needs to be accessed using a KeyValueBinding
	@objc dynamic var segmentEnabled: Bool = false {
		didSet {
			Swift.print("Bold segment is now \(segmentEnabled)")
		}
	}

	let segmentsEnabled = ValueBinder<NSSet>(NSSet()) { newValue in
		debugPrint("segmentsEnabled bound variable change: \(newValue)")
	}


	@IBAction func setAll(_: Any) {
		self.segmentsEnabled.wrappedValue = NSSet(array: [0, 1, 2])
	}

	func build() {
		self.toolbarContainer = DSFToolbar(
			"primary-segmented",
			allowsUserCustomization: true
		) {
			DSFToolbar.Segmented(
				"toolbar-styles-2",
				type: .Separated,
				switching: .selectAny,
				segmentWidths: 32
			) {
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_bold.template, scaling: .scaleProportionallyDown)
					.bindIsEnabled(try! KeyPathBinder(self, keyPath: \.segmentEnabled))
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_italic.template, scaling: .scaleProportionallyDown)
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_underline.template, scaling: .scaleProportionallyDown)
			}
			.label("Styles Separated")
			.bindSelection(segmentsEnabled)
			.legacySizes(minSize: NSSize(width: 105, height: 27))
			.action { selection in
				Swift.print("Styles Separated: New Selection -> \(selection)")
			}

			DSFToolbar.FixedSpace()

			DSFToolbar.Segmented(
				NSToolbarItem.Identifier("toolbar-styles-3"),
				type: .Separated,
				switching: .selectOne,
				segmentWidths: 32
			) {
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_left.template, scaling: .scaleProportionallyDown)
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_centre.template, scaling: .scaleProportionallyDown)
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_right.template, scaling: .scaleProportionallyDown)
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.ImageSet.toolbar_justify_full.template, scaling: .scaleProportionallyDown)
			}
			.label("Justify Separate")
			.legacySizes(minSize: NSSize(width: 140, height: 27))
			.action { selection in
				Swift.print("Justify Separate: New Selection -> \(selection)")
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
