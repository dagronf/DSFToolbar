//
//  DSFToolbar.Button.swift
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
	class Button: Core {
		private var button: NSButton?
		private var buttonToolbarItem: NSToolbarItem?

		var minWidth: NSLayoutConstraint?
		var maxWidth: NSLayoutConstraint?

		override var toolbarItem: NSToolbarItem? {
			return self.buttonToolbarItem
		}

		private func buildButton(type: NSButton.ButtonType) -> NSButton {
			let b = NSButton(frame: .zero)
			b.translatesAutoresizingMaskIntoConstraints = false
			b.bezelStyle = .texturedRounded
			b.title = self._title
			b.image = self._image
			b.imagePosition = self._imagePosition
			b.setButtonType(type)
			return b
		}

		private func updateDisplay() {
			// If there's an image and no title, set the state to imageOnly
			if self._title.count == 0 && self._image != nil {
				self.button?.imagePosition = .imageOnly
			}
			else if self._title.count > 0 && self._image == nil {
				self.button?.imagePosition = .noImage
			}
			else {
				self.button?.imagePosition = self._imagePosition
				self.button?.imageScaling = self._imageScaling
			}

			self.button?.image = self._image
			self.button?.title = self._title
			self.button?.bezelStyle = self._bezelStyle
		}

		public init(_ identifier: NSToolbarItem.Identifier,
			 buttonType: NSButton.ButtonType = .momentaryLight) {
			super.init(identifier)

			self.button = buildButton(type: buttonType)
			let a = NSToolbarItem(itemIdentifier: self.identifier)
			a.view = self.button
			self.buttonToolbarItem = a
		}

		public init(_ identifier: NSToolbarItem.Identifier, button: NSButton) {
			super.init(identifier)

			self.button = button
			let a = NSToolbarItem(itemIdentifier: self.identifier)
			a.view = self.button
			self.buttonToolbarItem = a
		}

		/// Cleanup
		override public func close() {
			self._action = nil

			self.button?.target = nil
			self.button = nil
			
			self.buttonToolbarItem?.view = nil
			self.buttonToolbarItem = nil

			super.close()
		}

		deinit {
			Swift.print("DSFToolbar.Button deinit")
		}

		// MARK: - Button type


		/// Set the type of button (on/off, toggle, momentary etc)
		/// - Parameter type: the type of button
		/// - Returns: self
		public func buttonType(_ type: NSButton.ButtonType) -> Button {
			self.button?.setButtonType(type)
			return self
		}

		// MARK: - Title

		private var _title: String = ""

		/// Set the title for the embedded button
		/// - Parameter title: the title
		/// - Returns: self
		///
		/// The title is different to the item label.  The title is attached to the embedded NSButton
		/// and not the toolbar item itself
		@discardableResult
		public func title(_ title: String) -> Self {
			self._title = title
			if self.label.count == 0 {
				self.label(title)
			}
			self.updateDisplay()
			return self
		}

		// MARK: - Image

		private var _image: NSImage? = nil

		/// The image to display on the button
		/// - Parameter image: the image
		/// - Returns: self
		@discardableResult
		public func image(_ image: NSImage) -> Self {
			self._image = image
			self.updateDisplay()
			return self
		}

		// MARK: - Image position

		private var _imagePosition: NSControl.ImagePosition = .imageLeft

		/// The position of the image on the embedded button (defaults to left)
		/// - Parameter position: The position for the image
		/// - Returns: self
		@discardableResult
		public func imagePosition(_ position: NSControl.ImagePosition) -> Self {
			self._imagePosition = position
			self.updateDisplay()
			return self
		}

		private var _imageScaling: NSImageScaling = .scaleNone

		/// The image scaling for the embedded button (defaults to left)
		/// - Parameter scaling: The type of scaling to use for the image on the embedded button
		/// - Returns: self
		@discardableResult
		public func imageScaling(_ scaling: NSImageScaling) -> Self {
			self._imageScaling = scaling
			self.updateDisplay()
			return self
		}

		private var _bezelStyle: NSButton.BezelStyle = .texturedRounded
		
		/// The position of the image on the embedded button (defaults to left)
		/// - Parameter position: The position for the image
		/// - Returns: self
		@discardableResult
		public func bezelStyle(_ bezelStyle: NSButton.BezelStyle) -> Self {
			self._bezelStyle = bezelStyle
			self.updateDisplay()
			return self
		}


		/// Set the minimum width for the button.
		/// - Parameter width: The width to set
		/// - Returns: self
		@discardableResult
		public func width(minVal: CGFloat? = nil, maxVal: CGFloat? = nil) -> Self {
			guard let b = self.button else { fatalError() }

			if let minVal = minVal, minVal > 0 {
				if self.minWidth == nil {
					self.minWidth = NSLayoutConstraint(
						item: b, attribute: .width,
						relatedBy: .greaterThanOrEqual,
						toItem: nil, attribute: .notAnAttribute,
						multiplier: 1, constant: 0)
					b.addConstraint(self.minWidth!)
				}
				if let w = self.minWidth {
					w.constant = minVal
				}
			}

			if let maxVal = maxVal, maxVal > 0 {
				if self.maxWidth == nil {
					self.maxWidth = NSLayoutConstraint(
						item: b, attribute: .width,
						relatedBy: .lessThanOrEqual,
						toItem: nil, attribute: .notAnAttribute,
						multiplier: 1, constant: 0)
					b.addConstraint(self.maxWidth!)
				}
				if let w = self.maxWidth {
					w.constant = maxVal
				}
			}

			b.needsUpdateConstraints = true
			return self
		}

		// MARK: - Action handling

		private var _action: ((NSButton) -> Void)?

		/// Provide a block to be called when the button is activated
		/// - Parameter action: the action block to be called
		/// - Returns: self
		@discardableResult
		public func action(_ action: @escaping (NSButton) -> Void) -> Self {
			self._action = action
			self.button?.target = self
			self.button?.action = #selector(itemPressed(_:))
			return self
		}

		/// Provide a target selector to be called when the button is activated
		/// - Parameters:
		///   - target: The target for the call
		///   - selector: The selector to call on the target
		/// - Returns: self
		public func action(_ target: AnyObject, selector: Selector) -> Self {
			self._action = nil
			self.button?.target = target
			self.button?.action = selector
			return self
		}

		@objc private func itemPressed(_: Any) {
			if let b = self.button {
				self._action?(b)
			}
		}
	}
}
