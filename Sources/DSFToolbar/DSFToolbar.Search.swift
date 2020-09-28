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
	class Search: Core {
		let maxWidth: CGFloat
		weak var _delegate: NSSearchFieldDelegate?

		var _searchField: NSSearchField?

		override var toolbarItem: NSToolbarItem? {
			return self.searchItem
		}

		override func close() {
			self._searchField = nil
			self._delegate = nil

			if #available(macOS 11, *) {
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

		init(identifier: NSToolbarItem.Identifier,
			 maxWidth: CGFloat = 180) {
			self.maxWidth = maxWidth
			super.init(identifier)
		}

		func delegate(_ delegate: NSSearchFieldDelegate) -> Search {
			self._delegate = delegate
			return self
		}

		override func enabledDidChange(to state: Bool) {
			self._searchField?.isEnabled = state
		}
	}
}
