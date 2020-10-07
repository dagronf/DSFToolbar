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

/// A bindings wrapper
internal class BindableAttribute<VALUETYPE>: NSObject {
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
