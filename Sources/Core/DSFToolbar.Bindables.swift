//
//  DSFToolbar.Bindables.swift
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

import Foundation

/// An untyped object binding container
///
/// The keypath for this binding is a String (use #keyPath).  This binder is useful for when
/// you're binding and need to erase the type.
///
/// For example, an NSToolbar.sizeMode is of type NSToolbar.SizeMode however the binding
/// is a UInt.  We can use this class to type-erase the binding from a UInt to an NSToolbar.SizeMode
internal class BindableUntypedAttribute<VALUETYPE>: NSObject {
	// The value of the attribute
	var value: VALUETYPE?

	private(set) weak var bindValueObserver: AnyObject?
	private(set) var bindValueKeyPath: String?

	private var valueChangeCallback: ((VALUETYPE) -> Void)?

	public var hasBinding: Bool {
		return self.bindValueObserver != nil &&
			self.bindValueKeyPath != nil
	}

	private(set) var bindingIsActive: Bool = false

	func setup(observable: AnyObject, keyPath: String) {
		self.bindValueObserver = observable
		self.bindValueKeyPath = keyPath
	}

	func updateValue(_ newValue: VALUETYPE) {
		guard let observer = self.bindValueObserver,
			  let keyPath = self.bindValueKeyPath else {
			// No binding was set for the attribute
			return
		}
		observer.setValue(newValue, forKey: keyPath)
	}

	func bind(valueChangeCallback: @escaping (VALUETYPE) -> Void) {

		if self.bindingIsActive == true {
			/// There's already a binding. Replace the callback
			self.valueChangeCallback = valueChangeCallback
			return
		}

		guard let observer = self.bindValueObserver,
			  let keyPath = self.bindValueKeyPath else {
			// No binding was set for the attribute
			return
		}

		self.valueChangeCallback = valueChangeCallback

		observer.addObserver(self, forKeyPath: keyPath, options: [.new], context: nil)
		self.bindingIsActive = true

		// Set the initial value from the binding if we can
		if let v = observer.value(forKeyPath: keyPath) as? VALUETYPE {
			valueChangeCallback(v)
		}
	}

	func unbind() {
		if !self.bindingIsActive {
			return
		}

		if let observer = self.bindValueObserver,
		   let keyPath = self.bindValueKeyPath {
			observer.removeObserver(self, forKeyPath: keyPath)
			self.bindingIsActive = false
		}
	}

	override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		if let changeCallback = self.valueChangeCallback,
		   let observerKeyPath = self.bindValueKeyPath, observerKeyPath == keyPath,
		   let newVal = change?[.newKey] as? VALUETYPE {
			changeCallback(newVal)
		}
		else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
}

/// A typed object binding container
internal class BindableTypedAttribute<VALUETYPE>: NSObject {
	// The value of the attribute
	var value: VALUETYPE?

	private(set) weak var bindValueObserver: NSObject?
	//private(set) var bindValueKeyPath: AnyKeyPath? // ReferenceWritableKeyPath<TYPE, VALUETYPE>?

	private var bindStringKeyPath: String?

	private var valueChangeCallback: ((VALUETYPE) -> Void)?

	public var hasBinding: Bool {
		return self.bindValueObserver != nil &&
			self.bindStringKeyPath != nil
	}

	private(set) var bindingIsActive: Bool = false

	func setup<TYPE>(observable: NSObject, keyPath: ReferenceWritableKeyPath<TYPE, VALUETYPE>) {
		self.bindValueObserver = observable

		// This is a little bit of a cheeky solution.  The internal 'addObserver' methods
		// use string-based keyPaths which are not typesafe.
		// As long as the object being observed (observable) is an @objc-defined object we can convert the
		// ReferenceWritableKeyPath to a String using NSExpression.
		// It's probably an abuse of the system, but it does allow us to make the interface type-safe
		// (which is useful because sometimes the bindable type is not clear, such
		// as NSSet for NSSegmentedControl.selected)
		let stringKeyPath = NSExpression(forKeyPath: keyPath).keyPath
		guard !stringKeyPath.isEmpty else {
			fatalError("Unable to convert keyPath \(keyPath)")
		}
		self.bindStringKeyPath = stringKeyPath
	}

	func updateValue(_ newValue: VALUETYPE) {
		guard let observer = self.bindValueObserver,
			  let keyPath = self.bindStringKeyPath else {
			// No binding was set for the attribute
			return
		}
		observer.setValue(newValue, forKey: keyPath)
	}

	func bind(valueChangeCallback: @escaping (VALUETYPE) -> Void) {

		if self.bindingIsActive == true {
			/// There's already a binding. Replace the callback
			self.valueChangeCallback = valueChangeCallback
			return
		}

		guard let observer = self.bindValueObserver,
			  let strKeyPath = self.bindStringKeyPath else {
			// No binding was set for the attribute
			return
		}

		self.valueChangeCallback = valueChangeCallback

		observer.addObserver(self, forKeyPath: strKeyPath, options: [.new], context: nil)
		self.bindingIsActive = true

		// Set the initial value from the binding if we can
		if let v = observer.value(forKeyPath: strKeyPath) as? VALUETYPE {
			valueChangeCallback(v)
		}
	}

	func unbind() {
		if !self.bindingIsActive {
			return
		}

		if let observer = self.bindValueObserver,
		   let strKeyPath = self.bindStringKeyPath {
			observer.removeObserver(self, forKeyPath: strKeyPath)
			self.bindingIsActive = false
		}
	}

	override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		if let changeCallback = self.valueChangeCallback,
		   let observerKeyPath = self.bindStringKeyPath,
		   observerKeyPath == keyPath,
		   let newVal = change?[.newKey] as? VALUETYPE {
			changeCallback(newVal)
		}
		else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
}
