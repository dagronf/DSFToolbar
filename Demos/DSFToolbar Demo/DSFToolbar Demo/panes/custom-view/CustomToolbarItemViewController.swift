//
//  CustomToolbarItemViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 30/9/20.
//

import Cocoa
import DSFToolbar_beta

class CustomToolbarItemViewController: NSViewController {

	@IBOutlet weak var channelLeft: NSLevelIndicator!
	@IBOutlet weak var channelRight: NSLevelIndicator!

	lazy var disabledFilter: CIFilter = {
		return CIFilter(name: "CIPhotoEffectTonal")!
	}()

	@objc dynamic var enabled = true {
		didSet {
			if enabled {
				self.channelLeft.contentFilters = []
				self.channelRight.contentFilters = []
			}
			else {
				self.channelLeft.contentFilters.append(self.disabledFilter)
				self.channelRight.contentFilters.append(self.disabledFilter)
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.
	}

}

extension CustomToolbarItemViewController: DSFToolbarViewControllerProtocol {
	func setEnabled(_ state: Bool) {
		self.enabled = state
	}

	func willShow() {

	}

	func willClose() {

	}
}
