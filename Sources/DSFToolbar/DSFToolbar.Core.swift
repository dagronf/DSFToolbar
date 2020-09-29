//
//  DSFToolbar.Core.swift
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

	class Core: NSObject {

		let identifier: NSToolbarItem.Identifier
		init(_ identifier: NSToolbarItem.Identifier) {
			self.identifier = identifier
		}

		lazy var rootItem: NSToolbarItem = {
			NSToolbarItem(itemIdentifier: self.identifier)
		}()

		var toolbarItem: NSToolbarItem? {
			return self.rootItem
		}

		public func close() {
			if let o = self._bindingLabelObject, let k = self._bindingLabelKeyPath {
				o.removeObserver(self, forKeyPath: k)
			}
			self._bindingLabelObject = nil

			if let o = self._bindingEnabledObject, let k = self._bindingEnabledKeyPath {
				o.removeObserver(self, forKeyPath: k)
			}
			self._bindingEnabledObject = nil
		}

		// Is the item selectable?
		private(set) var isSelectable: Bool = false

		/// Mark the toolbar item as being selectable or not selectable (default: not selectable)
		/// - Parameter selectable: Allow the toolbar to 'select' this item (or not)
		/// - Returns: Self
		///
		/// When the underlying NSToolbar is being created, if the item is marked as selectable then it will appear
		/// in the array of items presented to the the toolbar's delegate via toolbarSelectableItemIdentifiers
		///
		/// https://developer.apple.com/documentation/appkit/nstoolbardelegate/1516981-toolbarselectableitemidentifiers
		@discardableResult
		public func isSelectable(_ selectable: Bool) -> Self {
			isSelectable = selectable
			return self
		}

		/// Set the tooltip displayed for the item
		/// - Parameter msg: The tooltip message
		/// - Returns: self
		@discardableResult
		public func tooltip(_ msg: String) -> Self {
			self.toolbarItem?.toolTip = msg
			return self
		}

		// MARK: - Default items

		internal var isDefaultItem: Bool = true

		/// Mark the item as available on the 'default' toolbar presented to the user (default: true)
		/// - Parameter isDefault: true if the item should appear on the default toolbar, false otherwise
		/// - Returns: self
		public func isDefault(_ isDefault: Bool) -> Self {
			isDefaultItem = isDefault
			return self
		}

		// MARK: - Label and palette label

		/// The label for the toolbar item
		public var label: String {
			return self.toolbarItem?.label ?? ""
		}

		/// Set the label for the item.
		/// - Parameter label: The label to present to the user
		/// - Returns: self
		///
		/// The label is presented to the user when either the 'Show Text' or 'Show Icons and Text' option is
		/// set for the toolbar
		@discardableResult
		public func label(_ label: String) -> Self {
			self.toolbarItem?.label = label
			return self
		}

		/// Set the palette label for the item
		/// - Parameter label: The palette label to present to the user
		/// - Returns: self
		///
		/// The palette label is shown when the user is customizing the toolbar. It (usually) gives the user a slightly
		/// more descriptive text than the 'label'
		@discardableResult
		public func paletteLabel(_ label: String) -> Self {
			self.toolbarItem?.paletteLabel = label
			return self
		}

		// MARK: - Border

		/// When set on an item without a custom view, the button produced will have a bordered style.
		/// - Parameter state: the border state
		/// - Returns: self
		///
		/// Only available on 10.15 and later, however will silently be ignored on earlier versions to allow backwards
		/// compatibility
		public func isBordered(_ state: Bool) -> Self {
			if #available(macOS 10.15, *) {
				self.toolbarItem?.isBordered = state
			}
			return self
		}

		// MARK: - Label binding

		private var _bindingLabelObject: AnyObject?
		private var _bindingLabelKeyPath: String?

		/// Bind the label of the item to a key path (String)
		/// - Parameters:
		///   - object: The object to bind to
		///   - keyPath: The keypath identifying the member to bind to
		/// - Returns: self
		///
		/// Binding the label to a keypath allows the ability to change the label of this item dynamically when
		/// you need to. Note that (for Swift) you must mark the keyPath object as `@objc dynamic` for the change to
		/// take effect
		@discardableResult
		public func bindLabel(_ object: AnyObject, keyPath: String) -> Self {
			_bindingLabelObject = object
			_bindingLabelKeyPath = keyPath
			object.addObserver(self, forKeyPath: keyPath, options: [.new], context: nil)
			if let v = object.value(forKeyPath: keyPath) as? String {
				_ = self.label(v)
			}
			return self
		}

		// MARK: - Enable Binding

		var _bindingEnabledObject: AnyObject?
		var _bindingEnabledKeyPath: String?

		/// Bind the enabled status of the item to a key path (Bool)
		/// - Parameters:
		///   - object: The object to bind to
		///   - keyPath: The keypath identifying the member to bind to
		/// - Returns: self
		///
		/// Binding the enabled status to a keypath allows the ability to enable or disable this item dynamically when
		/// you need to. Note that (for Swift) you must mark the keyPath object as `@objc dynamic` for the change to
		/// take effect
		@discardableResult
		public func bindEnabled(_ object: AnyObject, keyPath: String) -> Self {
			_bindingEnabledObject = object
			_bindingEnabledKeyPath = keyPath
			object.addObserver(self, forKeyPath: keyPath, options: [.new], context: nil)
			if let v = object.value(forKeyPath: keyPath) as? Bool {
				self.toolbarItem?.isEnabled = v
				self.enabledDidChange(to: v)
			}
			return self
		}

		/// Called when the enabled state of an item changes.  Override to provide custom
		/// logic when your toolbar item changes its enabled state
		internal func enabledDidChange(to state: Bool) {
			// Do nothing
		}
	}
}

// MARK: - Binding observation

extension DSFToolbar.Core {
	override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		if _bindingLabelKeyPath == keyPath,
		   let newVal = change?[.newKey] as? String {
			_ = self.label(newVal)
		}
		else if _bindingEnabledKeyPath == keyPath,
		  let newVal = change?[.newKey] as? Bool {
			self.toolbarItem?.isEnabled = newVal
			self.enabledDidChange(to: newVal)
		}
		else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
}
