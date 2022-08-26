//
//  DSFToolbar.PopoverButton.swift
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
	class PopoverButton: Core {
		/// The popover button item
		public private(set) var button: NSButton?
		private var buttonToolbarItem: NSToolbarItem?
		private var _controller: NSViewController?

		private var _popover: NSPopover?

		override var toolbarItem: NSToolbarItem? {
			return self.buttonToolbarItem
		}

		public init(
			_ identifier: NSToolbarItem.Identifier,
			button: NSButton? = nil,
			popoverContentController: NSViewController
		) {
			self._controller = popoverContentController
			super.init(identifier)

			if let b = button {
				self.button = b
			}
			else {
				self.button = buildButton(type: .momentaryChange)
			}

			self.button?.target = self
			self.button?.action = #selector(self.action(_:))

			let a = NSToolbarItem(itemIdentifier: self.identifier)
			a.view = self.button
			a.label = "fish"
			self.buttonToolbarItem = a
		}

		public convenience init(
			_ identifier: String,
			button: NSButton? = nil,
			popoverContentController: NSViewController
		) {
			self.init(
				NSToolbarItem.Identifier(identifier),
				button: button,
				popoverContentController: popoverContentController
			)
		}

		override public func close() {
			// Make sure the popover is closed
			self._popover?.close()
			self._popover = nil

			self.button?.target = nil
			self.button = nil

			self.buttonToolbarItem?.view = nil
			self.buttonToolbarItem = nil

			self._controller = nil

			super.close()
		}

		deinit {
			Logging.memory("DSFToolbar.PopoverButton deinit")
		}

		// MARK: - Image

		private var _image: NSImage?

		/// Set the image to display in the item
		/// - Parameter image: the image
		/// - Returns: self
		@discardableResult
		public func image(_ image: NSImage) -> Self {
			self._image = image
			self.button?.image = image
			return self
		}

		@objc private func action(_ sender: Any) {
			self.showPopover()
		}

		private func showPopover() {
			if let p = _popover {
				p.close()
				self._popover = nil
			}

			let p = NSPopover()
			p.contentViewController = self._controller
			p.behavior = .transient
			p.delegate = self

			p.show(relativeTo: self.button!.bounds, of: self.button!, preferredEdge: .maxY)
		}
	}
}

extension DSFToolbar.PopoverButton {
	private func buildButton(type: NSButton.ButtonType) -> NSButton {
		let b = NSButton(frame: .zero)
		b.translatesAutoresizingMaskIntoConstraints = false
		b.bezelStyle = .regularSquare //  .texturedRounded
		b.setButtonType(type)
		return b
	}
}

extension DSFToolbar.PopoverButton: NSPopoverDelegate {
	public func popoverDidClose(_ notification: Notification) {
		_popover = nil
	}
}

// MARK: - Legacy sizing support

extension DSFToolbar.PopoverButton {
	override func changeToUseLegacySizing() {
		guard let b = self.button else {
			fatalError()
		}
		b.translatesAutoresizingMaskIntoConstraints = true
		b.removeConstraints(b.constraints)
	}
}

#endif
