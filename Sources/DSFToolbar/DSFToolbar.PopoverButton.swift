//
//  DSFToolbar.PopoverButton.swift
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
	class PopoverButton: Core {
		private var button: NSButton?
		private var buttonToolbarItem: NSToolbarItem? = nil
		private var _controller: NSViewController?

		override var toolbarItem: NSToolbarItem? {
			return self.buttonToolbarItem
		}

		private func buildButton(type: NSButton.ButtonType) -> NSButton {
			let b = NSButton(frame: .zero)
			b.translatesAutoresizingMaskIntoConstraints = false
			b.bezelStyle = .texturedRounded
			b.setButtonType(type)
			return b
		}

		public init(_ identifier: NSToolbarItem.Identifier,
			 popoverContentController: NSViewController) {
			self._controller = popoverContentController
			super.init(identifier)

			self.button = buildButton(type: .momentaryChange)

			self.button?.target = self
			self.button?.action = #selector(action(_:))

			let a = NSToolbarItem(itemIdentifier: self.identifier)
			a.view = self.button
			a.label = "fish"
			self.buttonToolbarItem = a
		}

		override public func close() {
			self.button?.target = nil
			self.button = nil

			self.buttonToolbarItem?.view = nil
			self.buttonToolbarItem = nil

			super.close()
		}

		var _popover: NSPopover? = nil

		@objc func action(_ sender: Any) {
			self.showPopover()
		}

		func showPopover() {
			if let p = _popover {
				p.close()
				_popover = nil
			}

			let p = NSPopover()
			p.contentViewController = self._controller
			p.behavior = .transient
			p.delegate = self

			p.show(relativeTo: self.button!.bounds, of: self.button!, preferredEdge: .maxY)
		}
	}
}

extension DSFToolbar.PopoverButton: NSPopoverDelegate {
	public func popoverDidClose(_ notification: Notification) {
		_popover = nil
	}
}
