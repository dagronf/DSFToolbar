//
//  DSFToolbar.Group.swift
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
	class Group: Core {

		public enum SelectionMode: Int {
			public typealias RawValue = Int
			case selectOne = 0	// NSToolbarItemGroup.SelectionMode.selectOne
			case selectAny = 1	// NSToolbarItemGroup.SelectionMode.selectAny
			case momentary = 2	// NSToolbarItemGroup.SelectionMode.momentary
		}

		internal var items: [DSFToolbar.Core] = []

		override var toolbarItem: NSToolbarItem? {
			return self.groupToolbarItem
		}

		lazy var groupToolbarItem: NSToolbarItemGroup = {
			return AppKit.NSToolbarItemGroup(itemIdentifier: self.identifier)
		}()

		public init(_ identifier: NSToolbarItem.Identifier,
					selectionMode: SelectionMode = .momentary,
					_ items: DSFToolbar.Core...) {
			super.init(identifier)
			self.items = items.map { $0 }
			let its = items.compactMap { $0.toolbarItem }
			self.groupToolbarItem.subitems = its
			self.mapGroupMode(selectionMode: selectionMode)
		}

		public init(_ identifier: NSToolbarItem.Identifier,
					selectionMode: SelectionMode = .momentary,
					children: [DSFToolbar.Core]) {
			super.init(identifier)
			self.items = children
			let its = items.compactMap { $0.toolbarItem }
			self.groupToolbarItem.subitems = its
			self.mapGroupMode(selectionMode: selectionMode)
		}

		public override func close() {
			self.items.forEach { $0.close() }
			super.close()
		}

		deinit {
			debugPrint("DSFToolbar.Group deinit")
		}

		private func mapGroupMode(selectionMode: SelectionMode) {
			if #available(OSX 10.15, *) {
				let mode: NSToolbarItemGroup.SelectionMode
				switch selectionMode {
				case .selectOne: mode = .selectOne
				case .selectAny: mode = .selectAny
				case .momentary: mode = .momentary
				}
				self.groupToolbarItem.selectionMode = mode
			}
		}

		override func changeToUseLegacySizing() {
			// Doesn't need to do anything
		}
	}
}
