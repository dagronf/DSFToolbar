//
//  DSFToolbar.FunctionBuilder.swift
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

#if os(macOS) || targetEnvironment(macCatalyst)

#if os(macOS)
import AppKit
#elseif targetEnvironment(macCatalyst)
import UIKit
#endif

// MARK: - Core function builder

#if swift(<5.3)
@_functionBuilder
public struct DSFToolbarBuilder {
	static func buildBlock() -> [DSFToolbar.Core] { [] }
}
#else
@resultBuilder
public struct DSFToolbarBuilder {
	static func buildBlock() -> [DSFToolbar.Core] { [] }
}

#endif

public extension DSFToolbarBuilder {
	static func buildBlock(_ settings: DSFToolbar.Core...) -> [DSFToolbar.Core] {
		settings
	}
}

// MARK: - Segment function builder

#if swift(<5.3)
@_functionBuilder
public struct DSFToolbarSegmentBuilder {
	static func buildBlock() -> [DSFToolbar.Segmented.Segment] { [] }
}
#else
@resultBuilder
public struct DSFToolbarSegmentBuilder {
	static func buildBlock() -> [DSFToolbar.Segmented.Segment] { [] }
}
#endif

public extension DSFToolbarSegmentBuilder {
	static func buildBlock(_ settings: DSFToolbar.Segmented.Segment...) -> [DSFToolbar.Segmented.Segment] {
		settings
	}
}

#if targetEnvironment(macCatalyst)

public extension DSFToolbar.Segmented {
	convenience init(
		_ identifier: NSToolbarItem.Identifier,
		selectionMode: NSToolbarItemGroup.SelectionMode = .momentary,
		@DSFToolbarSegmentBuilder builder: () -> [DSFToolbar.Segmented.Segment]) {
		self.init(identifier,
				  selectionMode: selectionMode,
				  children: builder())
	}
}

#else

public extension DSFToolbar.Segmented {
	convenience init(
		_ identifier: NSToolbarItem.Identifier,
		type: SegmentedType,
		switching: NSSegmentedControl.SwitchTracking = .selectAny,
		segmentWidths: CGFloat? = nil,
		@DSFToolbarSegmentBuilder builder: () -> [DSFToolbar.Segmented.Segment]) {
		self.init(identifier,
				  type: type,
				  switching: switching,
				  segmentWidths: segmentWidths,
				  segments: builder())
	}
}

#endif

#endif
