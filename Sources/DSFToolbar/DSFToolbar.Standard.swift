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

#if os(macOS) || targetEnvironment(macCatalyst)

#if os(macOS)
import AppKit
#elseif targetEnvironment(macCatalyst)
import UIKit
#endif

// MARK: Standard built-in toolbar item types

public extension DSFToolbar {
	/// An item to display the standard color palette
	private static let _showColors: Core = { Core(.showColors) }()
	static func ShowColors() -> Core { return DSFToolbar._showColors }

	/// A fixed space toolbar item
	private static let _fixedSpace: Core = { Core(.space) }()
	static func FixedSpace() -> Core { return DSFToolbar._fixedSpace }

	/// A flexible space toolbar item
	private static let _flexibleSpace: Core = { Core(.flexibleSpace) }()
	static func FlexibleSpace() -> Core { return DSFToolbar._flexibleSpace }

	/// Print
	private static let _print: Core = { Core(.print) }()
	static func Print() -> Core { return DSFToolbar._print }
}

#endif
