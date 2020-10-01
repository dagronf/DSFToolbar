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

public class DSFToolbar: NSObject {
	private let identifier: NSToolbar.Identifier

	/// The created NSToolbar.
	internal lazy var toolbar: NSToolbar = {
		let tb: NSToolbar
		tb = NSToolbar(identifier: self.identifier)
		tb.delegate = self
		return tb
	}()

	deinit {
		debugPrint("DSFToolbar: deinit")
	}

	// The items to be added to the touchbar
	private var items: [DSFToolbar.Core] = []
	public func addItems(_ items: [DSFToolbar.Core]) {
		self.items.append(contentsOf: items)
	}

	public func item<T>(identifier: NSToolbarItem.Identifier) -> T? {

		var items = self.items
		let groupContent = items.compactMap { ($0 as? DSFToolbar.Group)?.items }
		items += groupContent.flatMap { $0 }

		if let item = items.filter({ $0.identifier == identifier }).first {
			return item as? T
		}

		return nil
	}

	public init(toolbarIdentifier: NSToolbar.Identifier) {
		self.identifier = toolbarIdentifier
		super.init()
	}

	/// Attach the toolbar to a window.  This makes the toolbar visible in the window
	public var attachedWindow: NSWindow? {
		didSet {
			if let attachedWindow = self.attachedWindow {
				// Hook in our toolbar
				attachedWindow.toolbar = self.toolbar
			}
		}
	}

	/// Returns the height of the toolbar
	public var toolbarHeight: CGFloat? {
		guard let w = self.attachedWindow else {
			return nil
		}
		return w.frame.height - w.contentLayoutRect.height
	}

	/// Returns the offset from the top of the window to the top of the contentView so that it is
	/// not obscured by a toolbar
	public var contentOffsetForToolbar: CGFloat? {
		guard let w = self.attachedWindow else {
			return nil
		}
		if w.styleMask.contains(.fullSizeContentView) {
			return w.frame.height - w.contentLayoutRect.height
		}
		return 0
	}

	/// Build a new toolbar
	/// - Parameters:
	///   - toolbarIdentifier: The identifier for the toolbar. Should be unique within your application for customization and saving
	///   - allowsUserCustomization: is the user allowed to customize the toolbar
	///   - selectionDidChange: For toolbars that have selectable items, called when the toolbar selection changes
	///   - items: The toolbar items
	/// - Returns: The created toolbar
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
			// Check for duplicates
			if tb.items.map({ $0.identifier }).contains($0.identifier) {
				fatalError("Duplicate toolbar identifier \($0.identifier.rawValue)")
			}

			tb.items.append($0)
		}

		if let selChange = selectionDidChange {
			_ = tb.selectionChanged(selChange)
		}

		return tb.toolbar
	}

	/// Close the toolbar
	///
	/// You must call `close()` on a DSFToolbar object when you are finished to release any internal stores and/or
	/// binding observers.
	public func close() {

		// Make sure to detach ourselves if we aren't already
		// Our toolbar may have already been replaced by another, so we shouldn't just set it to nil
		if self.toolbar === self.attachedWindow?.toolbar {
			self.attachedWindow?.toolbar = nil
		}
		self.attachedWindow = nil

		// If we'd been observing selection changes, make sure we remove the observer
		if self._selectionChanged != nil {
			self.toolbar.removeObserver(self, forKeyPath: "selectedItemIdentifier")
			self._selectionChanged = nil
		}

		// Close each item
		self.items.forEach { item in
			item.close()
		}
		self.items = []
	}

	// MARK: - Selection change block

	private var _selectionChanged: ((NSToolbarItem.Identifier?) -> Void)?

	/// Supply a callback block to be called when the selection state of the toolbar changes
	/// - Parameter action: The block to call
	/// - Returns: self
	public func selectionChanged(_ action: @escaping (NSToolbarItem.Identifier?) -> Void) -> DSFToolbar {
		self._selectionChanged = action

		self.toolbar.addObserver(
			self,
			forKeyPath: "selectedItemIdentifier",
			options: [.old, .new], context: nil
		)

		return self
	}
}

// MARK: - Toolbar delegate

extension DSFToolbar: NSToolbarDelegate {

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

// MARK: - Binding observation

extension DSFToolbar {
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
}
