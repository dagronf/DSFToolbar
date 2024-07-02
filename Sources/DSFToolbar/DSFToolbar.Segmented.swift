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

import DSFValueBinders
import Foundation

#if os(macOS)

import AppKit

public extension DSFToolbar {
	/// A segmented toolbar item
	///
	/// ```swift
	/// DSFToolbar.Segmented("toolbar-styles-2",
	///    type: .Separated,
	///    switching: .selectAny,
	///    segmentWidths: 32
	/// ) {
	///    DSFToolbar.Segmented.Segment()
	///       .image(segmentImage_bold, scaling: .scaleProportionallyDown)
	///       .bindIsEnabled(to: self, withKeyPath: \MyViewController.segmentEnabled),
	///    DSFToolbar.Segmented.Segment()
	///       .image(segmentImage_underline, scaling: .scaleProportionallyDown),
	///    DSFToolbar.Segmented.Segment()
	///       .image(segmentImage_italic, scaling: .scaleProportionallyDown)
	/// }
	/// ```
	class Segmented: Core {
		/// The types of segmented control
		public enum SegmentedType {
			/// Individual segment elements
			case separated
			/// Grouped segments
			case grouped
		}

		/// Create a Segmented Control toolbar item
		/// - Parameters:
		///   - identifier: The unique identifier for the item.  Must be unique within the items in the toolbar
		///   - type: Segmented or Grouped
		///   - switching: The type of tracking behavior a segmented control exhibits
		///   - segmentWidths: (optional) set a fixed width for all segments. If not provided, size to fit content
		///   - segments: The segments
		public convenience init(
			_ identifier: String,
			type: SegmentedType,
			switching: NSSegmentedControl.SwitchTracking = .selectAny,
			segmentWidths: CGFloat? = nil,
			segments: [Segment]
		) {
			self.init(
				NSToolbarItem.Identifier(identifier),
				type: type,
				switching: switching,
				segmentWidths: segmentWidths,
				segments: segments
			)
		}

		/// Create a Segmented Control toolbar item
		/// - Parameters:
		///   - identifier: The unique identifier for the item.  Must be unique within the items in the toolbar
		///   - type: Segmented or Grouped
		///   - switching: The type of tracking behavior a segmented control exhibits
		///   - segmentWidths: (optional) set a fixed width for all segments. If not provided, size to fit content
		///   - segments: The segments to add
		public convenience init(
			_ identifier: NSToolbarItem.Identifier,
			type: SegmentedType,
			switching: NSSegmentedControl.SwitchTracking = .selectAny,
			segmentWidths: CGFloat? = nil,
			segments: Segment...
		) {
			self.init(identifier, type: type, switching: switching, segments: segments.map { $0 })
		}

		/// Create a Segmented Control toolbar item
		/// - Parameters:
		///   - identifier: The unique identifier for the item.  Must be unique within the items in the toolbar
		///   - type: Segmented or Grouped
		///   - switching: The type of tracking behavior a segmented control exhibits
		///   - segmentWidths: (optional) set a fixed width for all segments. If not provided, size to fit content
		///   - segments: The segments
		public init(
			_ identifier: NSToolbarItem.Identifier,
			type: SegmentedType,
			switching: NSSegmentedControl.SwitchTracking = .selectAny,
			segmentWidths: CGFloat? = nil,
			segments: [Segment]
		) {
			self.segments = segments

			super.init(identifier)

			let s = self.segmented
			s.translatesAutoresizingMaskIntoConstraints = false
			s.setContentHuggingPriority(.defaultHigh, for: .horizontal)
			s.trackingMode = switching
			s.segmentDistribution = .fillEqually
			s.segmentStyle = {
				switch type {
				case .grouped: return .capsule
				case .separated: return .separated
				}
			}()

			// Hook ourselves up to receive actions so we can reflect through our bindings and actions
			s.target = self
			s.action = #selector(self.itemPressed(_:))

			s.segmentCount = segments.count

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

		/// Called when the toolbar is being closed
		override public func close() {
			Logging.memory("DSFToolbar.Segmented [%@] close...", args: self.identifier.rawValue)

			self._actionBlock = nil

			// detach selection binding
			self._selectionBinding?.deregister(self)
			self._segmentEnabledBinding?.deregister(self)

			self.segmentedItem?.view = nil
			self.segmentedItem = nil

			self.segments.forEach { $0.close() }
			self.segments = []

			self.segmented.target = nil
			self.segmented.action = nil

			super.close()
		}

		deinit {
			Logging.memory("DSFToolbar.Segmented [%@] deinit", args: self.identifier.rawValue)
		}

		// private

		override var toolbarItem: NSToolbarItem? { self.segmentedItem }

		private let segmented = NSSegmentedControl(frame: .zero)
		private var segmentedItem: NSToolbarItem?

		private var segments: [Segment]

		// Action
		private var _actionBlock: ((IndexSet) -> Void)?

		// Binding
		private var _selectionBinding: ValueBinder<IndexSet>?
		private var _segmentEnabledBinding: ValueBinder<IndexSet>?
	}
}

// MARK: - Action(s)

extension DSFToolbar.Segmented {
	/// Define the action to call when the selection within the segmented control changes
	/// - Parameter block: The block to call, passing the newly selected segment indexes
	/// - Returns: Self
	public func action(_ action: @escaping (IndexSet) -> Void) -> Self {
		self._actionBlock = action
		return self
	}

	@objc private func itemPressed(_ sender: Any) {
		let selected: [Int] = self.segments.enumerated().compactMap { segment in
			if self.segmented.isSelected(forSegment: segment.offset) {
				return segment.offset
			}
			return nil
		}

		let indexes = IndexSet(selected)

		// Update the value in the binding if one has been set
		self._selectionBinding?.wrappedValue = indexes

		// If the action callback block has been set, call it
		self._actionBlock?(indexes)
	}
}

// MARK: - Selection bindings

extension DSFToolbar.Segmented {
	/// Bind the current selection of the segmented control
	/// - Parameters:
	///   - binder: The binding object to connect
	/// - Returns: self
	public func bindSelection(_ selectionBinder: ValueBinder<IndexSet>) -> Self {
		self._selectionBinding = selectionBinder
		selectionBinder.register(self) { [weak self] newValue in
			self?.setSelection(selectedItems: newValue)
		}
		return self
	}

	private func setSelection(selectedItems: IndexSet) {
		self.segments.enumerated().forEach { segment in
			self.segmented.setSelected(
				selectedItems.contains(segment.offset),
				forSegment: segment.offset
			)
		}
	}
}

// MARK: - Segment enable bindings

extension DSFToolbar.Segmented {
	/// A binding for enabling or disabling elements within the segmented control
	/// - Parameter segmentEnabledBinding: A set of indexes within the segmented control which should be enabled
	/// - Returns: self
	public func bindSegmentEnabled(_ segmentEnabledBinding: ValueBinder<IndexSet>) -> Self {
		self._segmentEnabledBinding = segmentEnabledBinding
		segmentEnabledBinding.register(self) { [weak self] newValue in
			self?.setEnabled(newValue)
		}
		return self
	}

	private func setEnabled(_ which: IndexSet) {
		self.segments.enumerated().forEach { item in
			let newValue = which.contains(item.offset)
			self.segmented.setEnabled(newValue, forSegment: item.offset)
		}
	}
}

// MARK: - Segment definition

public extension DSFToolbar.Segmented {
	/// Definition of a segment within a segmented control
	class Segment: NSObject {
		private var index: Int = -1
		private weak var parent: DSFToolbar.Segmented?

		// A work-around for enabled bindings not passing the initial value through.
		private var initialEnabledValue: Bool?
		private var initialImageValue: DSFImage?

		private var _title: String?

		/// Set the title for the segment
		public func title(_ string: String) -> Segment {
			self._title = string
			return self
		}

		// MARK: - Segment image and positioning

		private var _image: NSImage?
		private var _imageScaling: NSImageScaling = .scaleProportionallyUpOrDown

		/// Set the image for the segment
		public func image(_ image: NSImage, scaling: NSImageScaling = .scaleProportionallyUpOrDown) -> Segment {
			self._image = image
			self._imageScaling = scaling
			return self
		}

		// MARK: - Tooltip

		private var _tooltip: String?

		/// Set a tooltip for the segment
		public func tooltip(_ msg: String?) -> Segment {
			self._tooltip = msg
			return self
		}

		// MARK: - Segment enabled binding

		/// Individual segment binding
		private var _segmentEnabled: ValueBinder<Bool>?
		/// Individual segment image
		private var _segmentImageBinder: ValueBinder<DSFImage?>?

		/// Bind the enabled state for the segment to a member variable
		/// - Parameters:
		///   - binder: The binding object to connect
		/// - Returns: self
		public func bindIsEnabled(_ segmentEnabledBinder: ValueBinder<Bool>) -> Self {
			self._segmentEnabled = segmentEnabledBinder
			segmentEnabledBinder.register(self) { [weak self] newValue in
				self?.updateIsEnabled(newValue)
			}
			return self
		}

		private func updateIsEnabled(_ newValue: Bool) {
			// This might be called before the parent is set.
			if let parent = self.parent {
				parent.segmented.setEnabled(newValue, forSegment: self.index)
			}
			else {
				self.initialEnabledValue = newValue
			}
		}

		/// Bind the segment's image
		/// - Parameter imageBinder: The image binding
		/// - Returns: self
		public func bindImage(_ imageBinder: ValueBinder<DSFImage?>) -> Self {
			self._segmentImageBinder = imageBinder
			imageBinder.register(self) { [weak self] newValue in
				self?.updateImage(newValue)
			}
			return self
		}

		private func updateImage(_ image: DSFImage?) {
			if let parent = self.parent {
				parent.segmented.setImage(image, forSegment: self.index)
			}
			else {
				self.initialImageValue = image
			}
		}

		/// Create a segment
		/// - Parameter title: The segment title
		public init(title: String? = nil) {
			self._title = title
			super.init()
		}

		deinit {
			Logging.memory("DSFToolbar.Segmented.Segment deinit")
		}

		// Called when the segmented control is created, and we know our segment index is
		internal func onCreate(parent: DSFToolbar.Segmented, index: Int) {
			self.parent = parent
			self.index = index

			let segmented = parent.segmented

			// Label
			if let title = self._title {
				segmented.setLabel(title, forSegment: index)
			}

			// Image
			segmented.setImage(self._image, forSegment: index)
			segmented.setImageScaling(self._imageScaling, forSegment: index)

			segmented.alignment = .center

			// Tooltip
			if let t = self._tooltip {
				segmented.setToolTip(t, forSegment: index)
			}

			// The isEnabled binding _may_ have been set up before we actually exist
			// If we have the preCreateValue, it means that the binding was
			// created, but its initial value will not have been passed through
			// to the control. If so, push the value through
			if let p = self.initialEnabledValue {
				segmented.setEnabled(p, forSegment: index)
				self.initialEnabledValue = nil
			}

			if let p = self.initialImageValue {
				segmented.setImage(p, forSegment: index)
				self.initialImageValue = nil
			}
		}

		func close() {
			self._segmentEnabled = nil
			self.parent = nil
		}
	}
}

// MARK: - Legacy support

extension DSFToolbar.Segmented {
	// Legacy for older systems
	override func changeToUseLegacySizing() {
		// If we're using legacy sizing, we have to remove the constraints first
		self.segmented.translatesAutoresizingMaskIntoConstraints = true
		self.segmented.removeConstraints(self.segmented.constraints)
	}
}

#endif

/// NOTES:
///
/// IsBordered seems to take the concept of individual controls and makes them a
/// single unit.
/// For example,
///    a group with isBordered=true handles the selectionMode 'correctly'
///    a group with isBordered=false treats every child item as independent
