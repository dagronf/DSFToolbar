//
//  DSFToolbar.PopupMenu.swift
//
//  Copyright © 2023 Darren Ford. All rights reserved.
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
import DSFValueBinders

public extension DSFToolbar {
	/// A convenience for a toolbar item that provides a menu with selectable items
	class PopupMenu: Core {
		/// Create a popup button with the specified identifier and menu to display
		/// - Parameters:
		///   - identifier: The toolbar item's identifier
		///   - menu: The menu to display
		public init(
			_ identifier: NSToolbarItem.Identifier,
			menu: NSMenu
		) {
			self._popupMenu = menu

			super.init(identifier)

			let button = self._popupButton
			button.translatesAutoresizingMaskIntoConstraints = false
			button.bezelStyle = .texturedRounded
			button.imagePosition = .noImage
			button.menu = self._popupMenu

			let a = NSToolbarItem(itemIdentifier: self.identifier)
			a.view = self._popupButton
			a.target = self
			a.action = #selector(self.dummyTargetSelector(_:))
			self._popupButtonItem = a
		}

		/// Create a popup button with the specified identifier and menu to display
		/// - Parameters:
		///   - identifier: The toolbar item's identifier
		///   - menu: The menu to display
		public convenience init(_ identifier: String, menu: NSMenu) {
			self.init(NSToolbarItem.Identifier(identifier), menu: menu)
		}

		deinit {
			self.close()
			Logging.memory("DSFToolbar.PopupMenu deinit")
		}

		// Private

		private let _popupButton = NSPopUpButton(frame: .zero, pullsDown: false)
		private let _popupMenu: NSMenu
		private var _popupButtonItem: NSToolbarItem?
		private var _indexObserver: NSObjectProtocol?
		private var _selectedIndexBinder: ValueBinder<Int>?

		override var toolbarItem: NSToolbarItem? {
			return self._popupButtonItem
		}

		override func isEnabledDidChange(to state: Bool) {
			self._popupButtonItem?.isEnabled = state
			self._popupButton.isEnabled = state
		}

		override public func close() {
			self._indexObserver = nil
			self._popupButtonItem = nil
			super.close()
		}

		private var _title = ""
		private var _image: NSImage?
		private var _imagePosition: NSControl.ImagePosition = .imageLeft

		@objc private func dummyTargetSelector(_: Any) {}
	}
}

internal extension DSFToolbar.PopupMenu {
	override func changeToUseLegacySizing() {
		// If we're using legacy sizing, we have to remove the constraints first
		_popupButton.translatesAutoresizingMaskIntoConstraints = true
		_popupButton.removeConstraints(_popupButton.constraints)
	}
}

// MARK: - Bindings

public extension DSFToolbar.PopupMenu {
	/// Bind a valuebinder to the selected item's index in the menu
	func bindSelectedIndex(_ binder: ValueBinder<Int>) -> Self {
		self._selectedIndexBinder = binder
		binder.register(self) { [weak self] newValue in
			self?._popupButton.selectItem(at: newValue)
		}

		// Add an observer for the menu selections so we can update appropriately
		self._indexObserver = NotificationCenter.default.addObserver(
			forName: NSMenu.didSendActionNotification,
			object: self._popupMenu,
			queue: .main,
			using: { [weak self] notification in
				guard let `self` = self else { return }
				let index = self._popupButton.indexOfSelectedItem
				self._selectedIndexBinder?.wrappedValue = index
			}
		)

		return self
	}
}

#endif
