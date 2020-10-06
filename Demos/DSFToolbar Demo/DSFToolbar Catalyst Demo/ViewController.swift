//
//  ViewController.swift
//  DSFToolbar Catalyst Demo
//
//  Created by Darren Ford on 6/10/20.
//

import UIKit

class ViewController: UIViewController {

	#if targetEnvironment(macCatalyst)
	/// Toolbar wrapper for macCatalyst
	let toolbarContainer = ViewControllerToolbar()
	#endif

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}

	override func viewDidAppear(_: Bool) {

		#if targetEnvironment(macCatalyst)
		// Hook in the toolbar for Mac
		// A hack for the demo.  Demo only has one window.
		if let sn = UIApplication.shared.connectedScenes.first {
			self.toolbarContainer.hookToolbar(into: sn)
		}
		#endif
	}
}
