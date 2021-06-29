//
//  ViewController.swift
//  DSFToolbar Xcode 11 Demo
//
//  Created by Darren Ford on 6/10/20.
//

import Cocoa

import DSFToolbar_legacy

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	lazy var customToolbar: DSFToolbar = {

		DSFToolbar(
			toolbarIdentifier: NSToolbar.Identifier("view-controller"),
			allowsUserCustomization: true) {
				
				DSFToolbar.Item(NSToolbarItem.Identifier("toolbar-bold"))
					.label("Bold")
					.tooltip("Bold")
					.image(NSImage(named: "toolbar-bold")!)
					.isSelectable(true)
					.legacySizes(minSize: NSSize(width: 16, height: 16))
					.action { _ in
						Swift.print("Got bold!")
					}
				
				DSFToolbar.Item(NSToolbarItem.Identifier("toolbar-italic"))
					.label("Italic")
					.tooltip("Italic")
					.image(NSImage(named: "toolbar-italic")!)
					.isSelectable(true)
					.legacySizes(minSize: NSSize(width: 16, height: 16))
					.action { _ in
						Swift.print("Got italic!")
					}
				
				DSFToolbar.Item(NSToolbarItem.Identifier("toolbar-underline"))
					.label("Underline")
					.tooltip("Underline")
					.image(NSImage(named: "toolbar-underline")!)
					.isSelectable(true)
					.legacySizes(minSize: NSSize(width: 16, height: 16))
					.action { _ in
						Swift.print("Got underline!")
					}
				
				DSFToolbar.FlexibleSpace()
				
				DSFToolbar.Search(NSToolbarItem.Identifier("search"))
		}
		
	}()

	override func viewDidAppear() {
		super.viewDidAppear()

		self.customToolbar.attachedWindow = self.view.window
	}

}

