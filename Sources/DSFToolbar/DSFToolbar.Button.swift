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
import DSFValueBinders

public extension DSFToolbar {
	/// A standard toolbar item *containing* an NSButton
	///
	/// Example:
	///
	/// ```swift
	/// DSFToolbar.Button("justify-left")
	///    .title("Left")
	///    .width(minVal: 70)
	///    .image(justifyLeftImage)
	///    .imagePosition(.imageLeft)
	///    .imageScaling(.scaleProportionallyDown)
	///    .legacySizes(minSize: NSSize(width: 75, height: 27))
	/// ```
	class Button: Core {
		/// Create a toolbar button
		/// - Parameters:
		///   - identifier: The button's identifier
		///   - buttonType: The NSButton type
		public init(_ identifier: NSToolbarItem.Identifier, buttonType: NSButton.ButtonType = .momentaryLight) {
			super.init(identifier)

			let button = buildButton(type: buttonType)
			let a = NSToolbarItem(itemIdentifier: self.identifier)
			a.view = button
			self.buttonToolbarItem = a

			button.target = self
			button.action = #selector(itemPressed(_:))

			self.button = button
		}

		/// Create a toolbar button
		/// - Parameters:
		///   - identifier: The toolbar button's identifier
		///   - buttonType: The type of button for the toolbar item
		public convenience init(_ identifier: String, buttonType: NSButton.ButtonType = .momentaryLight) {
			self.init(NSToolbarItem.Identifier(identifier), buttonType: buttonType)
		}

		/// Create a toolbar button item using a pre-existing button item
		/// - Parameters:
		///   - identifier: the toolbar item identifier (must be unique within the toolbar)
		///   - button: The button to add to the toolbar item
		public init(_ identifier: NSToolbarItem.Identifier, button: NSButton) {
			super.init(identifier)

			self.button = button
			let a = NSToolbarItem(itemIdentifier: self.identifier)
			a.view = self.button
			self.buttonToolbarItem = a
		}

		/// Create a toolbar button item using a pre-existing button item
		/// - Parameters:
		///   - identifier: the toolbar item identifier (must be unique within the toolbar)
		///   - button: The button to add to the toolbar item
		public convenience init(_ identifier: String, button: NSButton) {
			self.init(NSToolbarItem.Identifier(identifier), button: button)
		}

		// private

		/// Cleanup
		override public func close() {
			self.button?.target = nil
			self.button = nil
			self._titleBinding = nil
			self._stateBinder = nil
			self._stateOnOffBinder = nil
			self._actionBlock = nil
			self._targetAction = nil
			self._image = nil
			self._alternateImage = nil
			self.buttonToolbarItem?.view = nil
			self.buttonToolbarItem = nil

			super.close()
		}

		deinit {
			Logging.memory("DSFToolbar.Button deinit")
		}

		private var button: NSButton?
		private var buttonToolbarItem: NSToolbarItem?

		var minWidth: NSLayoutConstraint?
		var maxWidth: NSLayoutConstraint?

		// Bindings and actions

		// Button press action
		private var _actionBlock: ((NSButton) -> Void)?
		private var _targetAction: (AnyObject, Selector)?

		// Embedded button styles

		// Button title
		private var _title = ""
		private var _titleBinding: ValueBinder<String>?

		// Button state
		private var _stateBinder: ValueBinder<NSControl.StateValue>?
		private var _stateOnOffBinder: ValueBinder<Bool>?

		// Button image
		private var _image: NSImage?
		private var _alternateImage: NSImage?
		// Button bezel style
		private var _bezelStyle: NSButton.BezelStyle = .texturedRounded
		// Button image scaling
		private var _imageScaling: NSImageScaling = .scaleNone
		// Button image position
		private var _imagePosition: NSControl.ImagePosition = .imageLeft

		override var toolbarItem: NSToolbarItem? {
			return self.buttonToolbarItem
		}
	}
}

// MARK: - Bindings

public extension DSFToolbar.Button {
	/// Bind the button title to a key path (String)
	/// - Parameters:
	///   - titleBinder: The binding object to connect to
	/// - Returns: self
	@discardableResult
	func bindTitle(_ titleBinder: ValueBinder<String>) -> Self {
		_titleBinding = titleBinder
		titleBinder.register(self) { [weak self] newValue in
			self?.title(newValue)
		}
		self.title(titleBinder.wrappedValue)
		return self
	}

	/// Bind the button state
	/// - Parameters:
	///   - titleBinder: The binding object to connect to
	/// - Returns: self
	@discardableResult
	func bindState(_ stateBinder: ValueBinder<NSControl.StateValue>) -> Self {
		self.button?.target = self
		self.button?.action = #selector(itemPressed(_:))

		_stateBinder = stateBinder
		stateBinder.register(self) { [weak self] newValue in
			self?.button?.state = newValue
		}
		self.button?.state = stateBinder.wrappedValue
		return self
	}

	/// Bind the on/off state
	/// - Parameters:
	///   - titleBinder: The binding object to connect to
	/// - Returns: self
	@discardableResult
	func bindOnOffState(_ stateOnOffBinder: ValueBinder<Bool>) -> Self {
		self.button?.target = self
		self.button?.action = #selector(itemPressed(_:))

		_stateOnOffBinder = stateOnOffBinder
		stateOnOffBinder.register(self) { [weak self] newValue in
			self?.button?.state = newValue ? .on : .off
		}
		self.button?.state = stateOnOffBinder.wrappedValue ? .on : .off
		return self
	}
}

// MARK: - Modifiers

public extension DSFToolbar.Button {
	/// Set the title for the embedded button
	/// - Parameter title: the title
	/// - Returns: self
	///
	/// The title is different to the item label.  The title is attached to the embedded NSButton
	/// and not the toolbar item itself
	@discardableResult
	func title(_ title: String) -> Self {
		self._title = title
		if self.label.count == 0 {
			self.label(title)
		}
		self.updateDisplay()
		return self
	}

	/// Set the type of button (on/off, toggle, momentary etc)
	/// - Parameter type: the type of button
	/// - Returns: self
	@discardableResult
	func buttonType(_ type: NSButton.ButtonType) -> Self {
		self.button?.setButtonType(type)
		return self
	}

	/// The image to display on the button
	/// - Parameter image: the image
	/// - Returns: self
	@discardableResult
	func image(_ image: NSImage) -> Self {
		self._image = image
		self.updateDisplay()
		return self
	}

	/// The image to display on the button
	/// - Parameter image: the image
	/// - Returns: self
	@discardableResult
	func alternateImage(_ image: NSImage) -> Self {
		self._alternateImage = image
		self.updateDisplay()
		return self
	}

	/// The position of the image on the embedded button (defaults to left)
	/// - Parameter position: The position for the image
	/// - Returns: self
	@discardableResult
	func imagePosition(_ position: NSControl.ImagePosition) -> Self {
		self._imagePosition = position
		self.updateDisplay()
		return self
	}

	/// The image scaling for the embedded button (defaults to left)
	/// - Parameter scaling: The type of scaling to use for the image on the embedded button
	/// - Returns: self
	@discardableResult
	func imageScaling(_ scaling: NSImageScaling) -> Self {
		self._imageScaling = scaling
		self.updateDisplay()
		return self
	}

	/// The position of the image on the embedded button (defaults to left)
	/// - Parameter position: The position for the image
	/// - Returns: self
	@discardableResult
	func bezelStyle(_ bezelStyle: NSButton.BezelStyle) -> Self {
		self._bezelStyle = bezelStyle
		self.updateDisplay()
		return self
	}

	/// Set the minimum and maximum widths for the button.
	/// - Parameter width: The width to set
	/// - Returns: self
	@discardableResult
	func width(minVal: CGFloat? = nil, maxVal: CGFloat? = nil) -> Self {
		guard let b = self.button else { fatalError() }

		if let minVal = minVal, minVal > 0 {
			if self.minWidth == nil {
				self.minWidth = NSLayoutConstraint(
					item: b, attribute: .width,
					relatedBy: .greaterThanOrEqual,
					toItem: nil, attribute: .notAnAttribute,
					multiplier: 1, constant: 0
				)
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
					multiplier: 1, constant: 0
				)
				b.addConstraint(self.maxWidth!)
			}
			if let w = self.maxWidth {
				w.constant = maxVal
			}
		}

		b.needsUpdateConstraints = true
		return self
	}
}

// MARK: - Actions

public extension DSFToolbar.Button {
	/// Provide a block to be called when the button is activated
	/// - Parameter action: the action block to be called
	/// - Returns: self
	@discardableResult
	func action(_ action: @escaping (NSButton) -> Void) -> Self {
		self._actionBlock = action
		return self
	}

	/// Provide a target selector to be called when the button is activated
	/// - Parameters:
	///   - target: The target for the call
	///   - selector: The selector to call on the target
	/// - Returns: self
	@discardableResult
	func action(_ target: AnyObject, selector: Selector) -> Self {
		self._targetAction = (target, selector)
		return self
	}

	@objc private func itemPressed(_: Any) {
		if let b = self.button {
			self._stateBinder?.wrappedValue = b.state
			self._stateOnOffBinder?.wrappedValue = (b.state != .off)
			self._actionBlock?(b)
			if let custom = _targetAction {
				_ = custom.0.perform(custom.1)
			}
		}
	}
}

extension DSFToolbar.Button {
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
		guard let button = self.button else { fatalError() }

		// If there's an image and no title, set the state to imageOnly
		if self._title.count == 0, self._image != nil {
			button.imagePosition = .imageOnly
		}
		else if self._title.count > 0, self._image == nil {
			button.imagePosition = .noImage
		}
		else {
			button.imagePosition = self._imagePosition
			button.imageScaling = self._imageScaling
		}

		button.image = self._image
		button.alternateImage = self._alternateImage
		button.title = self._title
		button.bezelStyle = self._bezelStyle
	}
}

// MARK: - Legacy sizing support

internal extension DSFToolbar.Button {
	override func changeToUseLegacySizing() {
		guard let b = self.button else {
			fatalError()
		}

		// If we're using legacy sizing, we have to remove the constraints first
		b.translatesAutoresizingMaskIntoConstraints = true
		b.removeConstraints(b.constraints)
	}
}

#endif
