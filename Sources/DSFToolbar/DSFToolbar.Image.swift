//
//  DSFToolbar.Image.swift
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

public extension DSFToolbar {
	class Image: Core {

		lazy var imageToolbarItem: NSToolbarItem = {
			return NSToolbarItem(itemIdentifier: self.identifier)
		}()

		override var toolbarItem: NSToolbarItem? {
			return self.imageToolbarItem
		}

		override public init(_ identifier: NSToolbarItem.Identifier) {
			super.init(identifier)
		}

		/// Called when the item is being closed
		public override func close() {
			self._action = nil
			self._isEnabled = nil
		}

		deinit {
			debugPrint("DSFToolbar.Item deinit")
		}

		// MARK: - Image

		/// Set the image to display in the item
		/// - Parameter image: the image
		/// - Returns: self
		@discardableResult
		public func image(_ image: NSImage) -> Self {
			self.toolbarItem?.image = image
			return self
		}

		// MARK: - Action

		private var _action: ((Image) -> Void)?

		/// Supply a callback block to be called when the item is activated (eg. clicked by the user)
		/// - Parameter action: The action block to call
		/// - Returns: self
		public func action(_ action: @escaping (Image) -> Void) -> Self {
			self._action = action

			self.toolbarItem?.target = self
			self.toolbarItem?.action = #selector(itemPressed(_:))

			return self
		}

		@objc private func itemPressed(_: Any) {
			self._action?(self)
		}

		// MARK: - Enabled state

		private var _isEnabled: (() -> Bool)?

		/// Supply a callback block to be called to determine the enabled state of the item
		/// - Parameter block: The block to call
		/// - Returns: self
		@discardableResult
		public func enabled(_ block: @escaping () -> Bool) -> Image {
			_isEnabled = block
			return self
		}

		/// Called when the enabled binding state changes
		override func enabledDidChange(to state: Bool) {
			// Called when the enabled binding state changes
		}
	}
}

// MARK: - Validation

extension DSFToolbar.Image: NSToolbarItemValidation {
	public func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
		let newState: Bool = {
			// If there's no action, then the item is always disabled
			if self._action == nil {
				return false
			}

			// If there's a binding, just return the current state
			if self._enabled.hasBinding {
				return item.isEnabled
			}

			if let block = self._isEnabled {
				return block()
			}

			// If there's enabled block or enabled binding then just always make enabled
			return true
		}()
		self.toolbarItem?.isEnabled = newState
		return newState
	}
}
