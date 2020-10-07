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

extension DSFToolbar.Search {

	/// Build a search item
	///  - If on macOS 11 (Big Sur) and later, uses the new NSSearchToolbarItem item
	///  - Otherwise, just uses an NSSearchField embedded in an NSToolbarItem
	internal func buildSearchItem() -> NSToolbarItem {
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
