//
//  utilities.swift
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

import Foundation

#if os(macOS)
import AppKit
public typealias DSFImage = NSImage
#else
import UIKit
public typealias DSFImage = UIImage
#endif

internal extension Sequence {
	/// Return unique elements in an array, given a predicate
	/// - Parameter includeElement: block determining whether the elements are equivalent
	func unique(_ predicate: (_ lhs: Element, _ rhs: Element) -> Bool) -> [Element] {
		var results = [Element]()
		forEach { (element) in
			if results.filter( { predicate(element, $0) }).count == 0 {
				results.append(element)
			}
		}
		return results
	}
}

internal extension Sequence where Element: Equatable {
	/// Return the unique elements in the array using Equatable as the predicate
	var unique: [Element] {
		return self.reduce(into: []) { uniqueElements, element in
			if !uniqueElements.contains(element) {
				uniqueElements.append(element)
			}
		}
	}
}
