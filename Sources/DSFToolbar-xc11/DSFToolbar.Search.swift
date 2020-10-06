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

#if os(macOS)

import AppKit

extension DSFToolbar {

	/// A toolbar search item.
	///
	/// Unavailable in Mac Catalyst
	public class Search: Core {
		let maxWidth: CGFloat
		weak var _delegate: NSSearchFieldDelegate?
		var _searchField: NSSearchField?

		override var toolbarItem: NSToolbarItem? {
			return self.searchItem
		}

		public override func close() {

			self._searchTextBinding.unbind()

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
			Logging.memory("DSFToolbar.Search deinit")
		}

		lazy var searchItem: NSToolbarItem = {
			var ms: NSSize? = nil

			let si = NSSearchField()

			if #available(macOS 10.13, *) {
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
			}
			else {
				ms = NSSize(width: self.maxWidth, height: 20)
			}

			si.delegate = self._delegate
			self._searchField = si
			let a = NSToolbarItem(itemIdentifier: self.identifier)
			a.view = si

			if let mss = ms {
				a.minSize = mss
			}

			return a
		}()

		/// Create a search field toolbar item
		/// - Parameters:
		///   - identifier: The identifier for the search field
		///   - maxWidth: The maximum width allowed for the search field
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

		// MARK: - Search Action

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

		// MARK: - Search text binding

		private let _searchTextBinding = BindableAttribute<String>()

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
			self._searchTextBinding.setup(observable: object, keyPath: keyPath)
			self._searchTextBinding.bind { [weak self] (newText) in
				self?._searchField?.stringValue = newText
			}
			return self
		}

		override func isEnabledDidChange(to state: Bool) {
			self._searchField?.isEnabled = state
		}
	}
}

extension DSFToolbar.Search: NSSearchFieldDelegate {
	public func controlTextDidChange(_ obj: Notification) {
		if let s = obj.object as? NSSearchField {
			let text = s.stringValue
			self._searchChange?(s, text)

			self._searchTextBinding.updateValue(text)
		}
	}
}

#endif
