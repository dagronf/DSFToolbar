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

	let settingsWindow = TitlebarPropertiesWindowController()

	let primaryView = PrimaryViewController()

	func applicationDidFinishLaunching(_ notification: Notification) {
		self.setup()

		self.settingsWindow.updateSettings = { [weak self] settings in
			guard let w = self?.window else { return }
			w.titleVisibility = settings.titlebarVisibility ? .visible : .hidden
			w.titlebarAppearsTransparent = settings.titlebarTransparent

			if settings.unifiedTitlebar {
				w.styleMask.insert(NSWindow.StyleMask.unifiedTitleAndToolbar)
			}
			else {
				w.styleMask.remove(NSWindow.StyleMask.unifiedTitleAndToolbar)
			}

			if settings.fullsizeContentView {
				w.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
			}
			else {
				w.styleMask.remove(NSWindow.StyleMask.fullSizeContentView)
			}
		}

		self.settingsWindow.showWindow(self)
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

