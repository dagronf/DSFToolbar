//
//  DSFToolbar.swift
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

internal var DSFToolbarBuilderAssociatedObjectHandle: UInt8 = 0

public class DSFToolbar: NSObject, NSToolbarDelegate {
	private let identifier: NSToolbar.Identifier

	lazy var toolbar: NSToolbar = {
		let tb: NSToolbar
		tb = NSToolbar(identifier: self.identifier)
		tb.delegate = self
		return tb
	}()

	deinit {
		Swift.print("Got here!")
	}

	// The items to be added to the touchbar
	private var items: [DSFToolbar.Core] = []
	public func addItems(_ items: [DSFToolbar.Core]) {
		self.items.append(contentsOf: items)
	}

	public init(toolbarIdentifier: NSToolbar.Identifier) {
		self.identifier = toolbarIdentifier
		super.init()
	}

	public static func Get(_ toolbar: NSToolbar) -> DSFToolbar? {
		return objc_getAssociatedObject(toolbar, &DSFToolbarBuilderAssociatedObjectHandle) as? DSFToolbar
	}

	public static func Build(
		toolbarIdentifier: NSToolbar.Identifier,
		allowsUserCustomization: Bool = false,
		selectionDidChange: ((NSToolbarItem.Identifier?) -> Void)? = nil,
		_ items: DSFToolbar.Core...
	) -> NSToolbar {
		let tb = DSFToolbar(toolbarIdentifier: toolbarIdentifier)

		tb.toolbar.allowsUserCustomization = allowsUserCustomization
		if allowsUserCustomization {
			tb.toolbar.autosavesConfiguration = true
		}

		items.forEach {
			tb.items.append($0)
		}

		// Tie the lifecycle of the DSFToolbar object to the lifecycle of the nstoolbar
		// so that we don't have to manually destroy it
		objc_setAssociatedObject(tb.toolbar, &DSFToolbarBuilderAssociatedObjectHandle, tb, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

		if let selChange = selectionDidChange {
			_ = tb.selectionChanged(selChange)
		}

		return tb.toolbar
	}

	public func close() {
		objc_setAssociatedObject(self.toolbar, &DSFToolbarBuilderAssociatedObjectHandle, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

		if self._selectionChanged != nil {
			self.toolbar.removeObserver(self, forKeyPath: "selectedItemIdentifier")
			self._selectionChanged = nil
		}

		self.items.forEach { item in
			item.close()
		}
		self.items = []
	}

	var _selectionChanged: ((NSToolbarItem.Identifier?) -> Void)?
	public func selectionChanged(_ action: @escaping (NSToolbarItem.Identifier?) -> Void) -> DSFToolbar {
		self._selectionChanged = action

		self.toolbar.addObserver(
			self,
			forKeyPath: "selectedItemIdentifier",
			options: [.old, .new], context: nil
		)

		return self
	}

	override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "selectedItemIdentifier" {
			let oldVal = change?[.oldKey] as? NSToolbarItem.Identifier
			let newVal = change?[.newKey] as? NSToolbarItem.Identifier
			if oldVal != newVal {
				self._selectionChanged?(newVal)
			}
		}
		else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}

	public func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
		return items.filter({ $0.isDefaultItem })
			.map { $0.identifier }
	}

	public func toolbarAllowedItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
		var i = items.map { $0.identifier }
		i.append(contentsOf: [.flexibleSpace, .space])
		return i.unique
	}

	public func toolbarSelectableItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
		return items.filter { $0.isSelectable }.map { $0.identifier }
	}

	public func toolbar(_: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
		let toolbarItem = self.items.first { item -> Bool in
			item.identifier == itemIdentifier
		}

		if let i = toolbarItem {
			return i.toolbarItem
		}
		return nil
	}
}
