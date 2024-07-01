//
//  Copyright © 2024 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#if os(macOS) || targetEnvironment(macCatalyst)

#if os(macOS)
import AppKit
#elseif targetEnvironment(macCatalyst)
import UIKit
#endif

import DSFValueBinders

public extension DSFToolbar {
	/// A standard toolbar item. Supports images and labels.
	///
	/// See [documentation](https://developer.apple.com/documentation/appkit/nstoolbaritem)
	///
	/// Example:
	///
	/// ```swift
	///   DSFToolbar.Item("toolbar-watermelon")
	///      .label("Watermelon")
	///      .image(watermelonImage)
	///      .willEnable { [weak self] in
	///         self?.isWatermelonEnabled() ?? false
	///      }
	///      .action { _ in
	///         Swift.print("Got grouped watermelon!")
	///      }
	/// ```
	class Item: Core {
		/// Create an image item
		override public init(_ identifier: NSToolbarItem.Identifier) {
			super.init(identifier)
		}

		/// Create a toolbar item
		/// - Parameter identifier: The toolbar item identifier
		public convenience init(_ identifier: String) {
			self.init(NSToolbarItem.Identifier(rawValue: identifier))
		}

		/// Called when the item is being closed
		override public func close() {
			self._actionBlock = nil
			self._isEnabledBlock = nil
			super.close()
		}

		deinit {
			Logging.memory("DSFToolbar.Item deinit")
			_imageBinder?.deregister(self)
		}

		// private

		private var _actionBlock: ((Item) -> Void)?
		private var _isEnabledBlock: (() -> Bool)?

		private var _imageBinder: ValueBinder<DSFImage>?

		lazy var imageToolbarItem: NSToolbarItem = {
			NSToolbarItem(itemIdentifier: self.identifier)
		}()

		override var toolbarItem: NSToolbarItem? {
			return self.imageToolbarItem
		}

		// Called when the enabled binding state changes
		override func isEnabledDidChange(to enabled: Bool) {
			// Called when the enabled binding state changes
		}
	}
}

// MARK: - Modifiers

extension DSFToolbar.Item {
	/// Set the image to display in the item
	/// - Parameter image: the image
	/// - Returns: self
	@discardableResult
	public func title(_ title: String) -> Self {
		if #available(macOS 10.15, *) {
			self.toolbarItem?.title = title
		}
		return self
	}

	/// Set the image to display in the item
	/// - Parameter image: the image
	/// - Returns: self
	@discardableResult
	public func image(_ image: DSFImage) -> Self {
		self.toolbarItem?.image = image
		return self
	}
}

// MARK: - Bindings

extension DSFToolbar.Item {
	/// Bind to the toolbar's image
	/// - Parameter image: The image binder
	/// - Returns: self
	@discardableResult
	public func bindImage(_ imageBinder: ValueBinder<DSFImage>) -> Self {
		self._imageBinder = imageBinder
		imageBinder.register(self) { [weak self] newImage in
			self?.toolbarItem?.image = newImage
		}
		return self
	}
}

// MARK: - Actions

extension DSFToolbar.Item {
	/// Supply a callback block to be called when the item is activated (eg. clicked by the user)
	/// - Parameter action: The action block to call
	/// - Returns: self
	public func action(_ action: @escaping (DSFToolbar.Item) -> Void) -> Self {
		self._actionBlock = action
		self.toolbarItem?.target = self
		self.toolbarItem?.action = #selector(itemPressed(_:))
		return self
	}

	@objc private func itemPressed(_: Any) {
		self._actionBlock?(self)
	}

	// MARK: - Enabled state
	/// Supply a callback block to be called to determine the enabled state of the item
	/// - Parameter block: The block to call
	/// - Returns: self
	@discardableResult
	public func willEnable(_ block: @escaping () -> Bool) -> DSFToolbar.Item {
		_isEnabledBlock = block
		return self
	}
}

#if os(macOS)

// MARK: - Validation

extension DSFToolbar.Item: NSToolbarItemValidation {
	public func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
		let newState: Bool = {
			// If there's no action, then the item is always disabled
			if self._actionBlock == nil {
				return false
			}

			// If there's a binding, just return the current state
			if self.hasEnabledBinding {
				return item.isEnabled
			}

			if let block = self._isEnabledBlock {
				return block()
			}

			// If there's enabled block or enabled binding then just always make enabled
			return true
		}()
		self.toolbarItem?.isEnabled = newState
		return newState
	}
}

#endif

#endif
