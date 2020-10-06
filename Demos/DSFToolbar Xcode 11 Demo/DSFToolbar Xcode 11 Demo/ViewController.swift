//
//  ViewController.swift
//  DSFToolbar Xcode 11 Demo
//
//  Created by Darren Ford on 6/10/20.
//

import Cocoa

import DSFToolbar_xc11

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

		DSFToolbar.Make(toolbarIdentifier: NSToolbar.Identifier("view-controller"),
						allowsUserCustomization: true) {

			DSFToolbar.FlexibleSpace()

			DSFToolbar.Search(NSToolbarItem.Identifier("search"))
		}

	}()

	override func viewDidAppear() {
		super.viewDidAppear()

		self.customToolbar.attachedWindow = self.view.window
	}

}

