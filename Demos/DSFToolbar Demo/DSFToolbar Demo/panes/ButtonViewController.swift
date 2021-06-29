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

	lazy var colorButton: NSButton = {
		let b = ColorDropdownButton()
		b.translatesAutoresizingMaskIntoConstraints = false
		b.addConstraint(NSLayoutConstraint(item: b, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48))

		b.showDropdownArrow = false
		b.selectedColor = .black

		b.target = self
		b.action = #selector(colorPicked(_:))

		return b
	}()

	@objc func colorPicked(_ sender: ColorDropdownButton) {

		NSColorPanel.shared.color = sender.selectedColor ?? .clear

		NSColorPanel.shared.setTarget(sender)
		NSColorPanel.shared.setAction(#selector(ColorDropdownButton.colorSelectorChange(_:)))
		NSColorPanel.shared.orderFront(self)
	}

	@objc dynamic var topTitle: String = "Top"

	func build() {
		self.toolbarContainer = DSFToolbar(
			toolbarIdentifier: NSToolbar.Identifier("primary-buttons"),
			allowsUserCustomization: true
		) {
			DSFToolbar.Button(NSToolbarItem.Identifier("button-0"), buttonType: .onOff)
				.title("Text only")
				.paletteLabel("This is the text")
				.width(minVal: 50)
				.legacySizes(minSize: NSSize(width: 75, height: 20))

			DSFToolbar.Button(NSToolbarItem.Identifier("button-1"), buttonType: .pushOnPushOff)
				.bezelStyle(.regularSquare)
				.tooltip("Image only")
				.paletteLabel("Add a person")
				.image(ProjectAssets.ImageSet.toolbar_button_person_add.template)
				.imagePosition(.imageOnly)
				.legacySizes(minSize: NSSize(width: 48, height: 48))

			DSFToolbar.Button(NSToolbarItem.Identifier("nonononononod"), button: colorButton)
				.title("pck")

			DSFToolbar.Group(NSToolbarItem.Identifier("button-group-1")) {
				DSFToolbar.Button(NSToolbarItem.Identifier("button-2"))
					.title("Left")
					.width(minVal: 70)
					.image(ProjectAssets.ImageSet.toolbar_button_click.template)
					.imagePosition(.imageLeft)
					.imageScaling(.scaleProportionallyDown)
					.legacySizes(minSize: NSSize(width: 75, height: 27))

				DSFToolbar.Button(NSToolbarItem.Identifier("button-3"))
					.title("Right")
					.width(minVal: 70)
					.image(ProjectAssets.ImageSet.toolbar_button_direction.template)
					.imagePosition(.imageRight)
					.imageScaling(.scaleProportionallyDown)
					.legacySizes(minSize: NSSize(width: 75, height: 27))
			}
			.legacySizes(minSize: NSSize(width: 160, height: 27))
			.label("First button group")
			.paletteLabel("Directions")

			DSFToolbar.Group(NSToolbarItem.Identifier("button-group-2")) {
				DSFToolbar.Button(NSToolbarItem.Identifier("button-4"), buttonType: .pushOnPushOff)
					.bindTitle(to: self, withKeyPath: \ButtonViewController.topTitle)
					.bezelStyle(.regularSquare)
					.width(minVal: 50, maxVal: 100)
					.image(ProjectAssets.ImageSet.toolbar_button_person_add.template)
					.imagePosition(.imageAbove)
					.imageScaling(.scaleProportionallyDown)
					.legacySizes(minSize: NSSize(width: 60, height: 60))

				DSFToolbar.Button(NSToolbarItem.Identifier("button-5"), buttonType: .pushOnPushOff)
					.title("Bottom")
					.bezelStyle(.regularSquare)
					.width(minVal: 50)
					.image(ProjectAssets.ImageSet.toolbar_button_person_add.template)
					.imagePosition(.imageBelow)
					.imageScaling(.scaleProportionallyDown)
					.legacySizes(minSize: NSSize(width: 60, height: 60))
			}
			.label("Second button group")
			.legacySizes(minSize: NSSize(width: 120, height: 60))


			// Add a button that isn't part of the default toolbar (you'll need to customize and add it to see it)

			DSFToolbar.Button(NSToolbarItem.Identifier("button-hidden-6"))
				.title("Hidden")
				.bezelStyle(.regularSquare)
				.isDefault(false)
				.width(minVal: 50)
				.image(ProjectAssets.ImageSet.toolbar_button_person_add.template)
				.imagePosition(.imageAbove)
				.imageScaling(.scaleProportionallyDown)
				.legacySizes(minSize: NSSize(width: 60, height: 60))
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
		NSColorPanel.shared.setTarget(nil)
		NSColorPanel.shared.setAction(nil)

		self.toolbarContainer?.close()
		self.toolbarContainer = nil
	}
}
