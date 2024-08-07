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

public extension DSFToolbar {
	/// A toolbar item that displays a popup menu
	///
	/// Example:
	///
	/// ```swift
	/// DSFToolbar.PopupButton("PopupButton", menu: self.popupMenu)
	///    .label("Popup")
	///    .image(ProjectAssets.ImageSet.toolbar_cog.template)
	///    .bindIsEnabled(to: self, withKeyPath: \MyViewController.popupMenuEnabled)
	/// ```
	class PopupButton: Core {
		/// Create a popup button with the specified identifier and menu to display
		/// - Parameters:
		///   - identifier: The toolbar item's identifier
		///   - menu: The menu to display
		public init(_ identifier: NSToolbarItem.Identifier, menu: NSMenu) {
			self._popupMenu = menu

			super.init(identifier)

			self.reconfigureMenu()

			let button = self._popupButton
			button.translatesAutoresizingMaskIntoConstraints = true
			button.bezelStyle = .texturedRounded

			button.imagePosition = .imageOnly
			button.imageScaling = .scaleProportionallyDown
			(button.cell as? NSPopUpButtonCell)?.arrowPosition = .arrowAtBottom

			button.menu = self._popupMenu

			let a = NSToolbarItem(itemIdentifier: self.identifier)
			a.view = self._popupButton
			a.target = self
			a.action = #selector(self.dummyTargetSelector(_:))
			self._popupButtonItem = a

			self.updateDisplay()
		}

		/// Create a popup button with the specified identifier and menu to display
		/// - Parameters:
		///   - identifier: The toolbar item's identifier
		///   - menu: The menu to display
		public convenience init(_ identifier: String, menu: NSMenu) {
			self.init(NSToolbarItem.Identifier(identifier), menu: menu)
		}

		// Private

		private var _popupButton = NSPopUpButton(frame: .zero, pullsDown: true)
		private var _popupMenu: NSMenu?
		private var _popupButtonItem: NSToolbarItem?

		override var toolbarItem: NSToolbarItem? {
			return self._popupButtonItem
		}

		override func isEnabledDidChange(to state: Bool) {
			self._popupButtonItem?.isEnabled = state
			self._popupButton.isEnabled = state
		}

		override public func close() {
			self._popupMenu = nil
			self._popupButtonItem = nil

			super.close()
		}

		deinit {
			Logging.memory("DSFToolbar.PopupButton deinit")
		}

		override func changeToUseLegacySizing() {
			// If we're using legacy sizing, we have to remove the constraints first
			_popupButton.translatesAutoresizingMaskIntoConstraints = true
			_popupButton.removeConstraints(_popupButton.constraints)
		}

		private var _title = ""
		private var _image: NSImage?
		private var _imagePosition: NSControl.ImagePosition = .imageLeft

		@objc private func dummyTargetSelector(_: Any) {}
	}
}

// MARK: - Modifier(s)

extension DSFToolbar.PopupButton {
	/// Set the title for the popup button
	/// - Parameter title: The title
	/// - Returns: Self
	@discardableResult
	public func title(_ title: String) -> Self {
		self._title = title
		self.updateDisplay()
		return self
	}

	/// Set the image for the popup button
	/// - Parameter image: The image
	/// - Returns: Self
	@discardableResult
	public func image(_ image: NSImage) -> Self {
		self._image = image
		self.updateDisplay()
		return self
	}

	/// Set the image position for the popup button
	/// - Parameter position: The image position
	/// - Returns: Self
	@discardableResult
	public func imagePosition(_ position: NSControl.ImagePosition) -> Self {
		self._imagePosition = position
		self.updateDisplay()
		return self
	}
}

extension DSFToolbar.PopupButton {
	private func updateDisplay() {
		guard let p = self._popupMenu,
				p.items.count > 0,
				p.items[0].tag == -5201
		else {
			fatalError()
		}

		p.items[0].title = self._title

		if let i = self._image {
			p.items[0].image = i
		}

		// If there's an image and no title, set the state to imageOnly
		if self._title.count == 0, self._image != nil {
			self._popupButton.imagePosition = .imageOnly
		}
		else if self._title.count > 0, self._image == nil {
			self._popupButton.imagePosition = .noImage
		}
		else {
			self._popupButton.imagePosition = self._imagePosition
		}
	}

	private func reconfigureMenu() {
		let newI = NSMenuItem()
		newI.tag = -5201
		self._popupMenu?.insertItem(newI, at: 0)
	}
}

#endif
