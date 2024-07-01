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

	@IBOutlet weak var styleSelector: NSSegmentedControl!

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

	// The binding for the styles selection
	let styleSelectedBinding = ValueBinder<IndexSet>(IndexSet()) { newValue in
		debugPrint("segmentsSelected bound variable change: \(newValue)")
	}

	// This is the binder for the toolbar justification segment enabling
	let justificationEnabledBinding = ValueBinder(IndexSet([0, 1, 2, 3])) { newValue in
		debugPrint("justificationEnabledBinding changed: \(newValue.map { $0 })")
	}

	@IBAction func setAll(_: Any) {
		self.styleSelectedBinding.wrappedValue = IndexSet([0, 1, 2])
	}

	@IBAction func styleEnableChanged(_ sender: NSSegmentedControl) {
		var enabled = IndexSet()
		(0 ..< sender.segmentCount).forEach { index in
			if sender.isSelected(forSegment: index) {
				enabled.insert(index)
			}
		}
		self.justificationEnabledBinding.wrappedValue = enabled
	}
	

	func build() {
		self.toolbarContainer = DSFToolbar(
			"primary-segmented",
			allowsUserCustomization: true
		) {
			DSFToolbar.Segmented(
				"toolbar-text-style",
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
			.bindSelection(styleSelectedBinding)
			.legacySizes(minSize: NSSize(width: 105, height: 27))
			.action { selection in
				Swift.print("Styles Separated: New Selection -> \(selection)")
			}

			DSFToolbar.FixedSpace()

			DSFToolbar.Segmented(
				NSToolbarItem.Identifier("toolbar-text-justification"),
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
			.bindSegmentEnabled(self.justificationEnabledBinding)
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
