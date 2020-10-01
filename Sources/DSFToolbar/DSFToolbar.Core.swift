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
			self._label.unbind()
			self._enabled.unbind()
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

			guard let ti = self.toolbarItem else {
				fatalError()
			}

			ti.label = label

			// If the user hasn't provided a palette label, set it to the label (older version support)
			if ti.paletteLabel.count == 0 {
				ti.paletteLabel = label
			}

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

		let _label = BindableAttribute<String>()

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
		public func bindLabel(to object: AnyObject, withKeyPath keyPath: String) -> Self {
			self._label.setup(observable: object, keyPath: keyPath)
			self._label.bind { [weak self] newText in
				self?.label(newText)
			}
			return self
		}

		// MARK: - Enable Binding

		let _enabled = BindableAttribute<Bool>()

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
		public func bindEnabled(to observable: NSObject, withKeyPath keyPath: String) -> Self {
			self._enabled.setup(observable: observable, keyPath: keyPath)
			self._enabled.bind { [weak self] newEnabledState in
				self?.toolbarItem?.isEnabled = newEnabledState
				self?.enabledDidChange(to: newEnabledState)
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

// MARK: - Legacy sizing support

extension DSFToolbar.Core {

	@objc func changeToUseLegacySizing() {
		// By default, do nothing
	}

	/// Set the minSize and maxSize of the toolbar item to the provided sizes.
	///
	/// For older macOS versions, toolbar constraints layout is buggy as hell, and its far more
	/// reliable (but less flexible) to use minSize and maxSize.
	///
	/// Setting a legacy size will only affect layouts pre 10.13 (High Sierra) - newer systems
	/// will just ignore these if they are set.
	public func legacySizes(minSize: NSSize? = nil, maxSize: NSSize? = nil) -> Self {
		if #available(macOS 10.13, *) {
			return self
		}

		// Notify the toolbar item that we need to do anything special BEFORE changing
		// the sizing to legacy.
		// For example, a button toolbar item uses constraints to set the size and the position,
		// so when legacy is requested from an older macOS the button is asked to 'convert' itself
		// to legacy min/max sizing.
		self.changeToUseLegacySizing()

		if let s = minSize {
			self.toolbarItem?.minSize = s
		}
		if let s = maxSize {
			self.toolbarItem?.maxSize = s
		}
		return self
	}
}
