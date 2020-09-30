//
//  PopoverContentController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 27/9/20.
//

import Cocoa

class PopoverContentController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

	var color: NSColor?

	var colorChange: ((NSColor?) -> Void)?


	@IBAction func selectedColor(_ sender: ColorButton) {
		self.color = sender.backgroundColor
		self.colorChange?(self.color)
	}
    
}

@IBDesignable
class ColorButton: NSButton {
	@IBInspectable var backgroundColor: NSColor? {
		didSet {
			self.layer?.backgroundColor = self.backgroundColor?.cgColor
		}
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		self.setup()
	}

	override func viewDidMoveToSuperview() {
		super.viewDidMoveToSuperview()
		self.setup()
	}

	func setup() {
		self.wantsLayer = true
		self.layer?.backgroundColor = self.backgroundColor?.cgColor
	}
}
