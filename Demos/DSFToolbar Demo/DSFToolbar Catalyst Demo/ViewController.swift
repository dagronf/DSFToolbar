//
//  ViewController.swift
//  DSFToolbar Catalyst Demo
//
//  Created by Darren Ford on 5/10/20.
//

import UIKit

class ViewController: UIViewController {
	/// Toolbar wrapper for macCatalyst
	let toolbarContainer = ViewControllerToolbar()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}

	override func viewDidAppear(_: Bool) {
		// Hook in the toolbar
		// A hack for the demo.  Demo only has one window.
		if let sn = UIApplication.shared.connectedScenes.first {
			self.toolbarContainer.hookToolbar(into: sn)
		}
	}
}
