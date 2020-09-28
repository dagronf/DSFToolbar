//
//  DSFToolbar.PopupButton.swift
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
	class PopupButton: Core {

		private var _popupButton: NSButton? = nil
		private var _popupMenu: NSMenu? = nil
		private var _popupButtonItem: NSToolbarItem?

		override var toolbarItem: NSToolbarItem? {
			return self._popupButtonItem
		}

		public override func close() {
			self._popupButton = nil
			self._popupMenu = nil
			self._popupButtonItem = nil
			if let o = self._bindingEnabledObject, let k = self._bindingEnabledKeyPath {
				o.removeObserver(self, forKeyPath: k)
			}
			self._bindingEnabledObject = nil
		}

		deinit {
			debugPrint("DSFToolbar.PopupButton deinit")
		}

		private func updateDisplay() {
			guard let p = self._popupMenu,
			   p.items.count > 0,
			   p.items[0].tag == -5201 else {
				fatalError()
			}
			
			p.items[0].title = self._title

			if let i = self._image {
				p.items[0].image = i
			}

			// If there's an image and no title, set the state to imageOnly
			if self._title.count == 0 && self._image != nil {
				self._popupButton?.imagePosition = .imageOnly
			}
			else if self._title.count > 0 && self._image == nil {
				self._popupButton?.imagePosition = .noImage
			}
			else {
				self._popupButton?.imagePosition = self._imagePosition
			}
		}

		private var _title: String = ""
		public func title(_ title: String) -> Self {
			self._title = title
			self.updateDisplay()
			return self
		}
		
		private var _image: NSImage? = nil
		public func image(_ image: NSImage) -> Self {
			self._image = image
			self.updateDisplay()
			return self
		}

		private var _imagePosition: NSControl.ImagePosition = .imageLeft
		public func imagePosition(_ position: NSControl.ImagePosition) -> Self {
			self._imagePosition = position
			self.updateDisplay()
			return self
		}

		private func reconfigureMenu() {
			let newI = NSMenuItem()
			newI.tag = -5201
			self._popupMenu?.insertItem(newI, at: 0)
		}

		override func enabledDidChange(to state: Bool) {
			self._popupButtonItem?.isEnabled = state
			self._popupButton?.isEnabled = state
		}

		init(_ identifier: NSToolbarItem.Identifier,
			 menu: NSMenu) {

			_popupMenu = menu.copy() as? NSMenu

			super.init(identifier)

			self.reconfigureMenu()

			let button = NSPopUpButton(frame: .zero, pullsDown: true)
			button.translatesAutoresizingMaskIntoConstraints = true
			button.bezelStyle = .texturedRounded

			button.imagePosition = .imageOnly
			button.imageScaling = .scaleProportionallyDown
			(button.cell as? NSPopUpButtonCell)?.arrowPosition = .arrowAtBottom
			self._popupButton = button

			button.menu = _popupMenu

			let a = NSToolbarItem(itemIdentifier: self.identifier)
			a.view = self._popupButton
			a.target = self
			a.action = #selector(dummyTargetSelector(_:))
			self._popupButtonItem = a

			self.updateDisplay()
		}

		@objc func dummyTargetSelector(_ sender: Any) {

		}
	}
	
}
