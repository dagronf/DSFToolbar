//
//  DSFToolbar.Separator.Legacy.swift
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
		public init(_ identifier: NSToolbarItem.Identifier,
			 splitView: NSSplitView,
			 dividerIndex: Int) {

			// Do nothing.  Not supported on pre 11 systems
			self.separatorToolbarItem = nil

			super.init(identifier)
		}

		deinit {
			Logging.memory("DSFToolbar.Separator deinit")
		}
	}
}

#endif
