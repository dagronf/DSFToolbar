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

	var imageIndex = 0

	@IBAction func rotate(_ sender: Any) {
		imageIndex += 1
		if imageIndex == images.count {
			imageIndex = 0
		}

		image1Binder.wrappedValue = images[imageIndex % 4]
		image2Binder.wrappedValue = images[(imageIndex + 1) % 4]
		image3Binder.wrappedValue = images[(imageIndex + 2) % 4]
		image4Binder.wrappedValue = images[(imageIndex + 3) % 4]
	}
	

	let images = [
		ProjectAssets.Image.i1.withRenderingMode(.alwaysTemplate),
		ProjectAssets.Image.i2.withRenderingMode(.alwaysTemplate),
		ProjectAssets.Image.i3.withRenderingMode(.alwaysTemplate),
		ProjectAssets.Image.i4.withRenderingMode(.alwaysTemplate),
	]

	private lazy var image1Binder = ValueBinder<DSFImage?>(images[imageIndex % 4])
	private lazy var image2Binder = ValueBinder<DSFImage?>(images[(imageIndex + 1) % 4])
	private lazy var image3Binder = ValueBinder<DSFImage?>(images[(imageIndex + 2) % 4])
	private lazy var image4Binder = ValueBinder<DSFImage?>(images[(imageIndex + 3) % 4])

	private let titleSelection = ValueBinder(IndexSet(integer: 0)) { newValue in
		debugPrint("Title selection changed -> is now \(newValue.map { $0 })")
	}

	func build() {
		self.toolbarContainer = DSFToolbar(
			"primary-segmented",
			allowsUserCustomization: true
		) {
			DSFToolbar.Segmented(
				"toolbar-titled",
				type: .grouped,
				switching: .selectOne
			) {
				DSFToolbar.Segmented.Segment()
					.title("left")
				DSFToolbar.Segmented.Segment()
					.title("center")
				DSFToolbar.Segmented.Segment()
					.title("right")
			}
			.label("Text titles")
			.bindSelection(titleSelection)

			DSFToolbar.FixedSpace()

			DSFToolbar.Segmented(
				"toolbar-images",
				type: .grouped,
				switching: .selectAny
			) {
				DSFToolbar.Segmented.Segment()
					.bindImage(image1Binder)
				DSFToolbar.Segmented.Segment()
					.bindImage(image2Binder)
				DSFToolbar.Segmented.Segment()
					.bindImage(image3Binder)
				DSFToolbar.Segmented.Segment()
					.bindImage(image4Binder)
			}
			.label("image binding")

			DSFToolbar.FixedSpace()

			DSFToolbar.Segmented(
				"toolbar-text-style",
				type: .separated,
				switching: .selectAny,
				segmentWidths: 32
			) {
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.Image.toolbar_bold.withRenderingMode(.alwaysTemplate), scaling: .scaleProportionallyDown)
					.bindIsEnabled(try! KeyPathBinder(self, keyPath: \.segmentEnabled))
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.Image.toolbar_italic.withRenderingMode(.alwaysTemplate), scaling: .scaleProportionallyDown)
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.Image.toolbar_underline.withRenderingMode(.alwaysTemplate), scaling: .scaleProportionallyDown)
			}
			.label("Styles Separated")
			.bindSelection(styleSelectedBinding)
			.legacySizes(minSize: NSSize(width: 105, height: 27))
			.action { selection in
				debugPrint("Styles Separated: New Selection -> \(selection)")
			}

			DSFToolbar.FixedSpace()

			DSFToolbar.Segmented(
				NSToolbarItem.Identifier("toolbar-text-justification"),
				type: .separated,
				switching: .selectOne,
				segmentWidths: 32
			) {
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.Image.toolbar_justify_left.template, scaling: .scaleProportionallyDown)
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.Image.toolbar_justify_centre.template, scaling: .scaleProportionallyDown)
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.Image.toolbar_justify_right.template, scaling: .scaleProportionallyDown)
				DSFToolbar.Segmented.Segment()
					.image(ProjectAssets.Image.toolbar_justify_full.template, scaling: .scaleProportionallyDown)
			}
			.label("Justify Separate")
			.bindSegmentEnabled(self.justificationEnabledBinding)
			.legacySizes(minSize: NSSize(width: 140, height: 27))
			.action { selection in
				debugPrint("Justify Separate: New Selection -> \(selection)")
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
