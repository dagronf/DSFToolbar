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

		//// Is the item selectable?

		private(set) var isSelectable: Bool = false
		public func selectable(_ selectable: Bool) -> Self {
			isSelectable = selectable
			return self
		}

		///// Tooltip

		@discardableResult
		public func tooltip(_ msg: String) -> Self {
			self.toolbarItem?.toolTip = msg
			return self
		}

		//// LABEL

		var label: String {
			return self.toolbarItem?.label ?? ""
		}

		@discardableResult
		public func label(_ label: String) -> Self {
			self.toolbarItem?.label = label
			return self
		}

		@discardableResult
		public func paletteLabel(_ label: String) -> Self {
			self.toolbarItem?.paletteLabel = label
			return self
		}

		var _bindingLabelObject: AnyObject?
		var _bindingLabelKeyPath: String?
		public func bindLabel(_ object: AnyObject, keyPath: String) -> Self {
			_bindingLabelObject = object
			_bindingLabelKeyPath = keyPath
			object.addObserver(self, forKeyPath: keyPath, options: [.new], context: nil)
			if let v = object.value(forKeyPath: keyPath) as? String {
				_ = self.label(v)
			}
			return self
		}

		//// ENABLED

		var _bindingEnabledObject: AnyObject?
		var _bindingEnabledKeyPath: String?
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
		func enabledDidChange(to state: Bool) {
			// Do nothing
		}

		func isBordered(_ state: Bool) -> Self {
			if #available(macOS 10.15, *) {
				self.toolbarItem?.isBordered = state
			}
			return self
		}


		private(set) public var isDefaultItem: Bool = true
		func setDefaultItem(_ isDefault: Bool) -> Self {
			isDefaultItem = isDefault
			return self
		}

		//// OBSERVER

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

}
