//
//  DSFToolbar.Image.swift
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
	class Image: Core, NSToolbarItemValidation {

		public override func close() {
			self._action = nil
		}

		lazy var imageToolbarItem: NSToolbarItem = {
			return NSToolbarItem(itemIdentifier: self.identifier)
		}()

		override var toolbarItem: NSToolbarItem? {
			return self.imageToolbarItem
		}

		deinit {
			Swift.print("DSFToolbar.Item deinit")
		}

		//// ACTION

		private var _action: ((Image) -> Void)?
		public func action(_ action: @escaping (Image) -> Void) -> Self {
			self._action = action

			self.toolbarItem?.target = self
			self.toolbarItem?.action = #selector(itemPressed(_:))

			return self
		}

		@objc func itemPressed(_: Any) {
			self._action?(self)
		}

		/// IMAGE

		public func image(_ image: NSImage) -> Self {
			self.toolbarItem?.image = image
			return self
		}

		//// ENABLED

		private var _enabled: (() -> Bool)?
		public func enabled(_ block: @escaping () -> Bool) -> Image {
			_enabled = block
			return self
		}

		override func enabledDidChange(to state: Bool) {

		}

		//// Selected

		var _bindingSelectedObject: AnyObject?
		var _bindingSelectedKeyPath: String?
		public func bindSelected(_ object: AnyObject, keyPath: String) -> Image {
			_bindingSelectedObject = object
			_bindingSelectedKeyPath = keyPath
			object.addObserver(self, forKeyPath: keyPath, options: [.new], context: nil)
			if let v = object.value(forKeyPath: keyPath) as? Bool {
				self.toolbarItem?.isEnabled = v
			}

			return self
		}


		//////

		override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
			if _bindingLabelKeyPath == keyPath,
			  let newVal = change?[.newKey] as? String {
				_ = self.label(newVal)
			}
			else {
				super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
			}
		}

		public func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
			let newState: Bool = {
				// If there's no action, then the item is always disabled
				if self._action == nil {
					return false
				}

				// If there's a binding, just return the current state
				if self._bindingEnabledObject != nil {
					return item.isEnabled
				}

				if let block = self._enabled {
					return block()
				}

				// If there's enabled block or enabled binding then just always make enabled
				return true
			}()
			self.toolbarItem?.isEnabled = newState
			return newState
		}
	}
}
