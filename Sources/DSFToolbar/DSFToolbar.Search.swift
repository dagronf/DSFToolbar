//
//  DSFToolbar.Search.swift
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

extension DSFToolbar {
	public class Search: Core {
		let maxWidth: CGFloat
		weak var _delegate: NSSearchFieldDelegate?

		var _searchField: NSSearchField?

		override var toolbarItem: NSToolbarItem? {
			return self.searchItem
		}

		public override func close() {

			if let o = self._bindingSearchTextObject, let k = self._bindingSearchTextKeyPath {
				o.removeObserver(self, forKeyPath: k)
			}
			self._bindingSearchTextObject = nil

			self._searchField = nil
			self._delegate = nil

			if #available(macOS 11, *) {
				// No need to do anything
			}
			else {
				self.toolbarItem?.view = nil
			}

			super.close()
		}

		deinit {
			Swift.print("DSFToolbar.Search deinit")
		}

		lazy var searchItem: NSToolbarItem = {
			if #available(macOS 11, *) {
				let si = NSSearchToolbarItem(itemIdentifier: self.identifier)
				si.searchField.delegate = self._delegate
				self._searchField = si.searchField
				return si
			}
			else {
				let si = NSSearchField()
				si.translatesAutoresizingMaskIntoConstraints = false
				si.addConstraint(
					NSLayoutConstraint(
						item: si,
						attribute: .width,
						relatedBy: .lessThanOrEqual,
						toItem: nil, attribute: .notAnAttribute,
						multiplier: 1, constant: self.maxWidth
					)
				)
				si.delegate = self._delegate
				self._searchField = si
				let a = NSToolbarItem(itemIdentifier: self.identifier)
				a.view = si
				return a
			}
		}()

		public init(_ identifier: NSToolbarItem.Identifier,
			 maxWidth: CGFloat = 180) {
			self.maxWidth = maxWidth
			super.init(identifier)
		}


		/// Set the delegate for the search field
		/// - Parameter delegate: The object to act as the search field's delegate
		/// - Returns: self
		@discardableResult
		public func delegate(_ delegate: NSSearchFieldDelegate) -> Search {
			self._delegate = delegate
			self._searchField?.delegate = delegate
			return self
		}

		private var _searchChange: ((NSSearchField, String) -> Void)?

		/// Provide a block to be called when the text in the search field changes
		/// - Parameter action: the action block to be called
		/// - Returns: self
		@discardableResult
		public func searchChange(_ action: @escaping (NSSearchField, String) -> Void) -> Self {
			self._searchChange = action
			self._delegate = self
			self._searchField?.delegate = self
			return self
		}


		private var _bindingSearchTextObject: AnyObject?
		private var _bindingSearchTextKeyPath: String?

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
		public func bindText(_ object: AnyObject, keyPath: String) -> Self {
			_bindingSearchTextObject = object
			_bindingSearchTextKeyPath = keyPath
			object.addObserver(self, forKeyPath: keyPath, options: [.new], context: nil)
			if let v = object.value(forKeyPath: keyPath) as? String {
				self._searchField?.stringValue = v
			}
			return self
		}

		override func enabledDidChange(to state: Bool) {
			self._searchField?.isEnabled = state
		}
	}
}

extension DSFToolbar.Search {
	override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		if _bindingSearchTextKeyPath == keyPath,
		   let newVal = change?[.newKey] as? String {
			self._searchField?.stringValue = newVal
		}
		else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
}

extension DSFToolbar.Search: NSSearchFieldDelegate {
	public func controlTextDidChange(_ obj: Notification) {
		if let s = obj.object as? NSSearchField {
			let text = s.stringValue
			self._searchChange?(s, text)

			if let o = self._bindingSearchTextObject,
			   let k = self._bindingSearchTextKeyPath {
				o.setValue(text, forKeyPath: k)
			}
		}
	}
}
