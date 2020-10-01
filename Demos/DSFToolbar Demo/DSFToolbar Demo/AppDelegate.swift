//
//  AppDelegate.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 29/9/20.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet var window: NSWindow!

	let primaryView = PrimaryViewController()

	func applicationDidFinishLaunching(_ notification: Notification) {
		self.setup()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

	func setup() {

		guard let cv = self.window.contentView else {
			return
		}

		let pv = primaryView.view
		cv.addSubview(pv)

		cv.addConstraints(
			NSLayoutConstraint.constraints(
				withVisualFormat: "H:|[v]|",
				options: .alignAllCenterX,
				metrics: nil,
				views: ["v": pv]))
		cv.addConstraints(
			NSLayoutConstraint.constraints(
				withVisualFormat: "V:|[v]|",
				options: .alignAllCenterX,
				metrics: nil,
				views: ["v": pv]))
	}

}

