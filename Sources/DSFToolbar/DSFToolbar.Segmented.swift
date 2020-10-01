//
//  DSFToolbar.Segmented.swift
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
	class Segmented: Core {
		public enum SegmentedType {
			case Separated
			case Grouped
		}

		private var segmented: NSSegmentedControl?
		private var segmentedItem: NSToolbarItem?

		override var toolbarItem: NSToolbarItem? {
			return self.segmentedItem
		}

		var segments: [Segment]

		/// Create a Segmented Control toolbar item
		/// - Parameters:
		///   - identifier: The unique identifier for the item.  Must be unique within the items in the toolbar
		///   - type: Segmented or Grouped
		///   - switching: The type of tracking behavior a segmented control exhibits
		///   - segmentWidths: (optional) set a fixed width for all segments. If not provided, size to fit content
		///   - segments: The segments
		public init(_ identifier: NSToolbarItem.Identifier,
					type: SegmentedType,
					switching: NSSegmentedControl.SwitchTracking = .selectAny,
					segmentWidths: CGFloat? = nil,
					_ segments: Segment...)
		{
			self.segments = segments.map { $0 }

			super.init(identifier)

			let s = NSSegmentedControl(frame: .zero)
			s.translatesAutoresizingMaskIntoConstraints = false
			s.setContentHuggingPriority(.defaultHigh, for: .horizontal)
			s.trackingMode = switching

			if #available(OSX 10.13, *) {
				s.segmentDistribution = .fillEqually
			}
			else {
				// Fallback on earlier versions
			}

			s.segmentStyle = {
				switch type {
				case .Grouped: return .capsule
				case .Separated: return .separated
				}
			}()

			s.segmentCount = segments.count
			self.segmented = s

			// Initialize each segment
			segments.enumerated().forEach { seg in
				if let w = segmentWidths {
					s.setWidth(w, forSegment: seg.offset)
				}
				seg.element.onCreate(parent: self, index: seg.offset)
			}

			let a = NSToolbarItem(itemIdentifier: self.identifier)
			a.view = s
			self.segmentedItem = a
		}

		override public func close() {
			self._action = nil
			self._selectionBinding.unbind()

			self.segmentedItem?.view = nil
			self.segmentedItem = nil

			self.segments.forEach { $0.close() }
			self.segments = []

			self.segmented?.target = nil
			self.segmented?.action = nil
			self.segmented = nil

			super.close()
		}

		deinit {
			debugPrint("DSFToolbar.Segmented deinit")
		}

		// MARK: - Segment Action

		var _action: ((Set<Int>) -> Void)?

		/// Define the action to call when the selection within the segmented control changes
		/// - Parameter block: The block to call, passing the selected segment indexes
		/// - Returns: Self
		public func action(_ action: @escaping (Set<Int>) -> Void) -> Segmented {
			self._action = action
			self.segmented?.target = self
			self.segmented?.action = #selector(itemPressed(_:))
			return self
		}

		@objc private func itemPressed(_: Any) {
			guard let s = self.segmented else { return }
			let selected: [Int] = self.segments.enumerated().compactMap { segment in
				if s.isSelected(forSegment: segment.offset) {
					return segment.offset
				}
				return nil
			}

			// Update the value in the binding if one has been set
			self._selectionBinding.updateValue(NSSet(array: selected))

			// If the action callback block has been set, call it
			self._action?(Set(selected))
		}

		// MARK: - Selection bindings

		private let _selectionBinding = BindableAttribute<NSSet>()

		/// Bind the selection of the item to a key path (NSSet<Int>)
		/// - Parameters:
		///   - object: The object to bind to
		///   - keyPath: The keypath identifying the member variable to bind to
		/// - Returns: self
		///
		/// Binding the selection to a keypath allows the ability to change the selection dynamically when
		/// you need to. Note that (for Swift) you must mark the keyPath object as `@objc dynamic` for the change to
		/// take effect
		public func bindSelection(_ object: AnyObject, keyPath: String) -> Self {
			_selectionBinding.setup(observable: object, keyPath: keyPath)
			_selectionBinding.bind { [weak self] newValue in
				self?.setSelection(selectedItems: newValue)
			}
			return self
		}

		private func setSelection(selectedItems: NSSet) {
			guard let s = self.segmented,
				  let sels = selectedItems as? Set<Int> else {
				fatalError()
			}

			self.segments.enumerated().forEach { segment in
				s.setSelected(sels.contains(segment.offset), forSegment: segment.offset)
			}
		}
	}
}

// MARK: - Segment definition

public extension DSFToolbar.Segmented {
	/// Definition of a segment within a segmented control
	class Segment: NSObject {
		var index: Int = -1
		weak var parent: DSFToolbar.Segmented?

		var _title: String = ""
		public func title(_ string: String) -> Segment {
			self._title = string
			return self
		}

		// MARK: - Segment image and positioning

		private var _image: NSImage?
		private var _imageScaling: NSImageScaling = .scaleProportionallyUpOrDown
		public func image(_ image: NSImage, scaling: NSImageScaling = .scaleProportionallyUpOrDown) -> Segment {
			self._image = image
			self._imageScaling = scaling
			return self
		}

		// MARK: - Segment enabled binding

		private let _segmentEnabled = BindableAttribute<Bool>()

		/// Bind the enabled state for the segment to a member variable
		/// - Parameters:
		///   - object: The object to bind to
		///   - keyPath: The key path for the member variable within 'object' (Bool)
		/// - Returns: self
		public func bindIsEnabled(to object: AnyObject, withKeyPath keyPath: String) -> Self {
			self._segmentEnabled.setup(observable: object, keyPath: keyPath)
			return self
		}

		public init(title: String = "") {
			self._title = title
			super.init()
		}

		deinit {
			debugPrint("DSFToolbar.Segmented.Segment deinit")
		}

		// Called when the segmented control is created, and we know our segment index is
		internal func onCreate(parent: DSFToolbar.Segmented, index: Int) {
			self.parent = parent
			self.index = index

			guard let segmented = parent.segmented else {
				fatalError()
			}

			// Label
			segmented.setLabel(self._title, forSegment: index)

			// Image
			segmented.setImage(self._image, forSegment: index)
			segmented.setImageScaling(self._imageScaling, forSegment: index)

			// Segment enable
			self._segmentEnabled.bind { [weak self] newState in
				// When the segment enable changes, make sure our parent segmentedcontrol knows
				self?.parent?.segmented?.setEnabled(newState, forSegment: index)
			}
		}

		func close() {
			self.parent = nil
			self._segmentEnabled.unbind()
		}
	}
}

// MARK: - Legacy support

extension DSFToolbar.Segmented {
	// Legacy for older systems
	override func changeToUseLegacySizing() {
		// If we're using legacy sizing, we have to remove the constraints first

		guard let b = self.segmented else {
			fatalError()
		}

		b.translatesAutoresizingMaskIntoConstraints = true
		b.removeConstraints(b.constraints)
	}
}
