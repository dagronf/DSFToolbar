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

#if os(macOS)

import AppKit
import DSFValueBinders

public extension DSFToolbar {
	/// A toolbar search item.
	///
	/// Unavailable in Mac Catalyst
	class Search: Core {
		override var toolbarItem: NSToolbarItem? {
			return self.searchToolbarItem
		}

		deinit {
			Logging.memory("DSFToolbar.Search deinit")
		}

		private lazy var searchToolbarItem: NSToolbarItem? = self.buildSearchItem()

		/// Create a search field toolbar item
		/// - Parameters:
		///   - identifier: The identifier for the search field
		///   - maxWidth: The maximum width allowed for the search field
		public init(
			_ identifier: NSToolbarItem.Identifier,
			maxWidth: CGFloat = 180
		) {
			self.maxWidth = maxWidth
			super.init(identifier)

			_ = self.searchToolbarItem
		}

		/// Create a search field toolbar item
		/// - Parameters:
		///   - identifier: The identifier for the search field
		///   - maxWidth: The maximum width allowed for the search field
		public convenience init(_ identifier: String, maxWidth: CGFloat = 100) {
			self.init(NSToolbarItem.Identifier(identifier), maxWidth: maxWidth)
		}

		// Private

		override public func close() {
			self._searchTextBinding = nil
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

		override func isEnabledDidChange(to state: Bool) {
			self._searchField?.isEnabled = state
		}

		private let maxWidth: CGFloat
		private weak var _delegate: NSSearchFieldDelegate?
		private var _searchField: NSSearchField?

		private var _searchChange: ((NSSearchField, String) -> Void)?
		private var _searchTextBinding: ValueBinder<String>?
	}
}

// MARK: - Modifiers

public extension DSFToolbar.Search {
	/// Set the placeholder text for the search field
	func placeholderText(_ text: String) -> Self {
		self._searchField?.placeholderString = text
		return self
	}

	/// Set the delegate for the search field
	/// - Parameter delegate: The object to act as the search field's delegate
	/// - Returns: self
	@discardableResult
	func delegate(_ delegate: NSSearchFieldDelegate) -> Self {
		self._delegate = delegate
		self._searchField?.delegate = delegate
		return self
	}
}

// MARK: - Actions

public extension DSFToolbar.Search {
	/// Provide a block to be called when the text in the search field changes
	/// - Parameter action: the action block to be called
	/// - Returns: self
	@discardableResult
	func onSearchTextChange(_ action: @escaping (NSSearchField, String) -> Void) -> Self {
		self._searchChange = action
		self._delegate = self
		self._searchField?.delegate = self
		return self
	}
}

// MARK: - Bindings

public extension DSFToolbar.Search {
	/// Bind the content of the search field to a value binder
	/// - Parameter searchBinder: The binding object
	/// - Returns: self
	@discardableResult
	func bindSearchText(_ searchBinder: ValueBinder<String>) -> Self {
		_searchTextBinding = searchBinder
		searchBinder.register(self) { [weak self] newValue in
			self?._searchField?.stringValue = newValue
		}
		self._searchField?.stringValue = searchBinder.wrappedValue
		self._searchField?.delegate = self
		return self
	}
}

extension DSFToolbar.Search: NSSearchFieldDelegate {
	public func controlTextDidChange(_ obj: Notification) {
		if let s = obj.object as? NSSearchField {
			let text = s.stringValue

			// Call the callback func if it has been set
			self._searchChange?(s, text)

			// Update the binding if it has been set
			self._searchTextBinding?.wrappedValue = text
		}
	}
}

extension DSFToolbar.Search {
	/// Build a search item
	///  - If on macOS 11 (Big Sur) and later, uses the new NSSearchToolbarItem item
	///  - Otherwise, just uses an NSSearchField embedded in an NSToolbarItem
	func buildSearchItem() -> NSToolbarItem {
		if #available(macOS 11, *) {
			let si = NSSearchToolbarItem(itemIdentifier: self.identifier)
			si.searchField.delegate = self._delegate
			self._searchField = si.searchField
			return si
		}
		else {
			var ms: NSSize?

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
		}
	}
}

#endif
