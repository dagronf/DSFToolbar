//
//  DSFToolbar.Separator.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
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

public extension DSFToolbar {
	/// A toolbar item representing a separator
	///
	/// Note that separators were introduced in macOS 11, for lower versions this item is ignored.
	///
	/// Not yet available in Mac Catalyst
	class Separator: Core {
		override var toolbarItem: NSToolbarItem? {
			return self.separatorToolbarItem
		}

		let separatorToolbarItem: NSToolbarItem? // NSTrackingSeparatorToolbarItem

		/// Create a separator item
		/// - Parameters:
		///   - identifier: the toolbar item identifier (must be unique within the toolbar)
		///   - splitView: The split view to track
		///   - dividerIndex: The divider index index within `splitView` to track
		public init(
			_ identifier: NSToolbarItem.Identifier,
			splitView: NSSplitView,
			dividerIndex: Int
		) {
			if #available(macOS 11.0, *) {
				self.separatorToolbarItem = NSTrackingSeparatorToolbarItem(
					identifier: identifier,
					splitView: splitView,
					dividerIndex: dividerIndex
				)
			}
			else {
				self.separatorToolbarItem = nil
			}

			super.init(identifier)
		}

		/// Create a separator item
		/// - Parameters:
		///   - identifier: the toolbar item identifier (must be unique within the toolbar)
		///   - splitView: The split view to track
		///   - dividerIndex: The divider index index within `splitView` to track
		public convenience init(
			_ identifier: String,
			splitView: NSSplitView,
			dividerIndex: Int
		) {
			self.init(
				NSToolbarItem.Identifier(identifier),
				splitView: splitView,
				dividerIndex: dividerIndex
			)
		}

		deinit {
			Logging.memory("DSFToolbar.Separator deinit")
		}
	}
}

#endif
