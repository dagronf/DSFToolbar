//
//  Utilities.swift
//  Simple Documentation Demo
//
//  Created by Darren Ford on 2/10/20.
//

import AppKit

/// Simple helper class to tell us when a window is going to close
class WindowCloseNotifier {
	private var windowCloseNotification: NSObjectProtocol?
	func observe(_ window: NSWindow, block: @escaping () -> Void) {
		self.windowCloseNotification = NotificationCenter.default.addObserver(
			forName: NSWindow.willCloseNotification,
			object: window,
			queue: OperationQueue.main) { _ in
			block()
		}

		// Since the window is closing, we no longer need to listen
		self.windowCloseNotification = nil
	}

	deinit {
		// Stop listening (if we are)
		self.windowCloseNotification = nil
	}
}
