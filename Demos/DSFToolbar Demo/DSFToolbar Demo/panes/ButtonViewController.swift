//
//  ButtonViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 30/9/20.
//

import Cocoa

import DSFToolbar

class ButtonViewController: NSViewController {

	var toolbarContainer: DSFToolbar?

    override func viewDidLoad() {
        super.viewDidLoad()

		self.build()
    }

	@objc dynamic var topTitle: String = "Top"

	func build() {
		self.toolbarContainer = DSFToolbar.Make(
			toolbarIdentifier: NSToolbar.Identifier("primary-buttons"),
			allowsUserCustomization: true
		) {
			DSFToolbar.Button(NSToolbarItem.Identifier("button-0"), buttonType: .onOff)
				.title("Text only")
				.paletteLabel("This is the text")
				.width(minVal: 50)

			DSFToolbar.Button(NSToolbarItem.Identifier("button-1"), buttonType: .pushOnPushOff)
				.bezelStyle(.regularSquare)
				.tooltip("Image only")
				.paletteLabel("Add a person")
				.image(ProjectAssets.ImageSet.toolbar_button_person_add.template)
				.imagePosition(.imageOnly)

			DSFToolbar.Group(NSToolbarItem.Identifier("button-group-1")) {
			DSFToolbar.Button(NSToolbarItem.Identifier("button-2"))
				.title("Left")
				.width(minVal: 50)
				.image(ProjectAssets.ImageSet.toolbar_button_click.template)
				.imagePosition(.imageLeft)
				.imageScaling(.scaleProportionallyDown)

			DSFToolbar.Button(NSToolbarItem.Identifier("button-3"))
				.title("Right")
				.width(minVal: 50)
				.image(ProjectAssets.ImageSet.toolbar_button_direction.template)
				.imagePosition(.imageRight)
				.imageScaling(.scaleProportionallyDown)
			}
			.label("First button group")

			DSFToolbar.Group(NSToolbarItem.Identifier("button-group-2")) {
				DSFToolbar.Button(NSToolbarItem.Identifier("button-4"), buttonType: .pushOnPushOff)
					.bindTitle(to: self, withKeyPath: "topTitle")
					.bezelStyle(.regularSquare)
					.width(minVal: 50, maxVal: 100)
					.image(ProjectAssets.ImageSet.toolbar_button_person_add.template)
					.imagePosition(.imageAbove)
					.imageScaling(.scaleProportionallyDown)

				DSFToolbar.Button(NSToolbarItem.Identifier("button-5"), buttonType: .pushOnPushOff)
					.title("Bottom")
					.bezelStyle(.regularSquare)
					.width(minVal: 50)
					.image(ProjectAssets.ImageSet.toolbar_button_person_add.template)
					.imagePosition(.imageBelow)
					.imageScaling(.scaleProportionallyDown)
			}
			.label("Second button group")

			// Add a button that isn't part of the default toolbar (you'll need to customize and add it to see it)

			DSFToolbar.Button(NSToolbarItem.Identifier("button-hidden-6"))
				.title("Hidden")
				.bezelStyle(.regularSquare)
				.isDefault(false)
				.width(minVal: 50)
				.image(ProjectAssets.ImageSet.toolbar_button_person_add.template)
				.imagePosition(.imageAbove)
				.imageScaling(.scaleProportionallyDown)
			}
	}


}


extension ButtonViewController: DemoContentViewController {
	static func Create() -> NSViewController {
		return ButtonViewController()
	}

	static func Title() -> String {
		return "Buttons"
	}

	var customToolbar: DSFToolbar? {
		return self.toolbarContainer
	}

	func cleanup() {
		self.toolbarContainer?.close()
		self.toolbarContainer = nil
	}
}
