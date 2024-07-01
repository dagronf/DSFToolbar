//
//  SampleViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 1/7/2024.
//

import Cocoa
import DSFToolbar
import DSFMenuBuilder

class SampleViewController: NSViewController {
	var toolbarContainer: DSFToolbar?
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.

		self.buildToolbar()
	}
}

extension SampleViewController {
	func buildToolbar() {
		self.toolbarContainer = DSFToolbar(
			toolbarIdentifier: "sample",
			allowsUserCustomization: true
		) {
			DSFToolbar.Item("toolbar-sidebar")
				.label("Sidebar")
				.image(DSFImage(named: "toolbar-show-sidebar")!)

			DSFToolbar.PopupMenu(
				"toolbar-zoom",
				menu: Menu {
					MenuItem("100%")
					MenuItem("150%")
					MenuItem("200%")
				}
					.menu
			)
			.label("Zoom")

			DSFToolbar.FlexibleSpace()

			DSFToolbar.Item("toolbar-text")
				.label("Text")
				.image(DSFImage(named: "toolbar-textbox")!)

			DSFToolbar.Item("toolbar-bigger")
				.label("Bigger")
				.image(DSFImage(named: "toolbar-text-bigger")!)

			DSFToolbar.Item("toolbar-smaller")
				.label("Smaller")
				.image(DSFImage(named: "toolbar-text-smaller")!)

			DSFToolbar.Item("toolbar-indent")
				.label("Indent")
				.image(DSFImage(named: "toolbar-text-indent")!)

			DSFToolbar.Item("toolbar-outdent")
				.label("Outdent")
				.image(DSFImage(named: "toolbar-text-outdent")!)

			DSFToolbar.FlexibleSpace()

			DSFToolbar.Item("toolbar-shape")
				.label("Shape")
				.image(DSFImage(named: "toolbar-shape")!)
				.action { item in
					Swift.print("toolbar-shape pressed")
				}

			DSFToolbar.Item("toolbar-forward")
				.label("Forward")
				.image(DSFImage(named: "toolbar-forward")!)
				.action { item in
					Swift.print("toolbar-formward pressed")
				}

			DSFToolbar.Item("toolbar-backward")
				.label("Backward")
				.image(DSFImage(named: "toolbar-backward")!)

			DSFToolbar.FlexibleSpace()

			DSFToolbar.Item("toolbar-comment")
				.label("Comment")
				.image(DSFImage(named: "toolbar-comment")!)

			DSFToolbar.Item("toolbar-share")
				.label("Share")
				.image(DSFImage(named: "toolbar-share")!)

		}
	}
}

extension SampleViewController: DemoContentViewController {
	static func Create() -> NSViewController {
		return SampleViewController()
	}

	static func Title() -> String {
		return "Sample"
	}

	var customToolbar: DSFToolbar? {
		return self.toolbarContainer
	}

	func cleanup() {
		self.toolbarContainer?.close()
		self.toolbarContainer = nil
	}
}

