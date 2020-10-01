//
//  DSFToolbar.View.swift
//  DSFToolbar
//
//  Created by Darren Ford on 25/9/20.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import AppKit

/// A view controller protocol to provide feedback during the toolbar lifecycle
public protocol DSFToolbarViewControllerProtocol {

	/// Called when the enabled state of the toolbarItem is changing
	func setEnabled(_ state: Bool)

	/// Called when the toolbar item is created and added to the toolbar
	func willShow()

	/// Called when the toolbar item is closing, and the view needs will go away
	func willClose()
}

public extension DSFToolbar {

	/// A toolbar item containing an arbitrary view.
	class View: Core {

		private var viewController: NSViewController? = nil

		private var externalViewController: DSFToolbarViewControllerProtocol? {
			return self.viewController as? DSFToolbarViewControllerProtocol
		}


		/// Create a toolbar item containing a custom view
		/// - Parameters:
		///   - identifier: The identifier
		///   - viewController: The view controller for the view to be inserted
		public init(_ identifier: NSToolbarItem.Identifier, viewController: NSViewController) {
			self.viewController = viewController
			super.init(identifier)

			self.toolbarItem?.view = self.viewController?.view

			// Tell the view controller that it's view has been added
			self.externalViewController?.willShow()
		}

		/// Called when the enabled binding state changes
		override func enabledDidChange(to state: Bool) {
			self.externalViewController?.setEnabled(state)
		}

		/// Called when the item is being closed
		public override func close() {

			// Tell the view controller that it's about to be destroyed
			self.externalViewController?.willClose()

			// Detach the view controller and the view from the toolbar item
			self.toolbarItem?.view = nil
			self.viewController = nil

			super.close()
		}

		deinit {
			debugPrint("DSFToolbar.View deinit")
		}
	}
}
