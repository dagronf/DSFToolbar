//
//  ColorDropdownButton.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 8/10/20.
//

import AppKit

class ColorDropdownButton: NSButton {
	var selectedColor: NSColor? {
		didSet {
			self.needsDisplay = true
		}
	}

	var trackingTag: NSView.TrackingRectTag? = nil

	enum ButtonState {
		case background
		case idle
		case mouseOver
		case pressed
	}

	var buttonState: ButtonState = .idle

	var showDropdownArrow: Bool = true

	override var acceptsFirstResponder: Bool {
		return true
	}

	@objc func colorSelectorChange(_ sender: NSColorPanel) {
		selectedColor = sender.color
	}

	var keyChange: WindowKeyChangeNotifier?

	override func viewDidMoveToWindow() {
		guard let w = self.window else { return }
		self.keyChange = WindowKeyChangeNotifier(w) { [weak self] (state) in
			guard let `self` = self else { return }
			self.buttonState = state ? .idle : .background
			self.needsDisplay = true
		}
	}


	override func drawFocusRingMask() {
		let backgroundPath = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), xRadius: 4, yRadius: 4)
		backgroundPath.fill()
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	override func layout() {
		super.layout()

		if let r = self.trackingTag {
			self.removeTrackingRect(r)
		}

		self.trackingTag = self.addTrackingRect(self.bounds, owner: self, userData: nil, assumeInside: false)
	}

	deinit {
		self.keyChange = nil
	}

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		self.setup()
	}

	override func viewDidMoveToSuperview() {
		super.viewDidMoveToSuperview()
		self.setup()
	}

	private func setup() {
		// Do nothing
	}

	override func mouseEntered(with event: NSEvent) {
		if buttonState != .background {
			buttonState = .mouseOver
		}
		self.needsDisplay = true
	}

	override func mouseDown(with event: NSEvent) {
		if buttonState != .background {
			buttonState = .pressed
		}
		self.needsDisplay = true

		self.performClick(self)
	}

	override func mouseUp(with event: NSEvent) {
		buttonState = .mouseOver
		self.needsDisplay = true
	}


	override func mouseExited(with event: NSEvent) {
		if buttonState != .background {
			buttonState = .idle
		}
		self.needsDisplay = true
	}

	override func draw(_ dirtyRect: NSRect) {
		self.drawCanvas(width: self.bounds.width, height: self.bounds.height)
	}

	func drawCanvas(width: CGFloat, height: CGFloat) {

		self.alphaValue = (self.buttonState == .background) ? 0.3 : 1.0

		//// background Drawing
		let backgroundPath = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: width, height: height), xRadius: 4, yRadius: 4)

		if self.buttonState == .mouseOver {
			NSColor.secondaryLabelColor.setFill()
		}
		else if buttonState == .pressed {
			NSColor.tertiaryLabelColor.withAlphaComponent(0.2).setFill()
		}
		else {
			NSColor.controlColor.setFill()
		}
		backgroundPath.fill()

		var r = CGRect(x: 0, y: 0, width: width, height: height)
		r = r.insetBy(dx: 4, dy: 4)

		if showDropdownArrow {
			r.size.width -= 12
		}

		//// progress Drawing
		let progressPath = NSBezierPath(roundedRect: r, xRadius: 2, yRadius: 2)
		self.selectedColor?.setFill()
		progressPath.fill()

		NSColor.textColor.setStroke()
		progressPath.lineWidth = 1
		progressPath.stroke()

		if showDropdownArrow {
			//// Bezier Drawing
			let bezierPath = NSBezierPath()

			let top = (height / 2) + 2

			bezierPath.move(to: NSPoint(x: width - 11, y: top - 3))
			bezierPath.line(to: NSPoint(x: width - 8, y: top))
			bezierPath.line(to: NSPoint(x: width - 5, y: top - 3))
			NSColor.textColor.setStroke()
			bezierPath.lineWidth = 1.2
			bezierPath.lineCapStyle = .round
			bezierPath.lineJoinStyle = .round
			bezierPath.stroke()
		}
	}
}
