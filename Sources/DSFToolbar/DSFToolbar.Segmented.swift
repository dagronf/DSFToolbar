//
//  DSFToolbar.Segmented.swift
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

import DSFValueBinders
import Foundation

#if os(macOS)

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

			// Hook ourselves up to receive actions so we can reflect through our bindings and actions
			s.target = self
			s.action = #selector(self.itemPressed(_:))

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
			segmentWidths _: CGFloat? = nil,
			segments: Segment...
		) {
			self.init(
				identifier,
				type: type,
				switching: switching,
				segments: segments.map { $0 })
		}

		/// Called when the toolbar is being closed
		override public func close() {
			self._action = nil

			// detach selection binding
			self._selectionBinding = nil

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
			Logging.memory("DSFToolbar.Segmented deinit")
		}

		// MARK: - Segment Action

		private var _action: ((Set<Int>) -> Void)?

		/// Define the action to call when the selection within the segmented control changes
		/// - Parameter block: The block to call, passing the selected segment indexes
		/// - Returns: Self
		public func action(_ action: @escaping (Set<Int>) -> Void) -> Segmented {
			self._action = action
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
			self._selectionBinding?.wrappedValue = NSSet(array: selected)

			// If the action callback block has been set, call it
			self._action?(Set(selected))
		}

		// MARK: - Selection bindings

		private var _selectionBinding: ValueBinder<NSSet>?

		/// Bind the selection of the item to a key path (NSSet<Int>)
		/// - Parameters:
		///   - binder: The binding object to connect
		/// - Returns: self
		public func bindSelection(_ selectionBinder: ValueBinder<NSSet>) -> Self {
			self._selectionBinding = selectionBinder
			selectionBinder.register(self) { [weak self] newValue in
				self?.setSelection(selectedItems: newValue)
			}
			self.setSelection(selectedItems: selectionBinder.wrappedValue)
			return self
		}

		private func setSelection(selectedItems: NSSet) {
			guard let s = self.segmented,
					let sels = selectedItems as? Set<Int>
			else {
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

		var _title = ""
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

		// MARK: - Tooltip

		private var _tooltip: String?

		/// Set a tooltip for the segment
		public func tooltip(_ msg: String?) -> Segment {
			self._tooltip = msg
			return self
		}

		// MARK: - Segment enabled binding

		private var _segmentEnabled: ValueBinder<Bool>?

		/// Bind the enabled state for the segment to a member variable
		/// - Parameters:
		///   - binder: The binding object to connect
		/// - Returns: self
		public func bindIsEnabled(_ segmentEnabledBinder: ValueBinder<Bool>) -> Self {
			self._segmentEnabled = segmentEnabledBinder
			segmentEnabledBinder.register(self) { [weak self] newValue in
				self?.updateIsEnabled(newValue)
			}
			self.updateIsEnabled(segmentEnabledBinder.wrappedValue)
			return self
		}

		private func updateIsEnabled(_ newValue: Bool) {
			self.parent?.segmented?.setEnabled(newValue, forSegment: self.index)
		}

		public init(title: String = "") {
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

			guard let segmented = parent.segmented else {
				fatalError()
			}

			// Label
			segmented.setLabel(self._title, forSegment: index)

			// Image
			segmented.setImage(self._image, forSegment: index)
			segmented.setImageScaling(self._imageScaling, forSegment: index)

			// Tooltip
			if #available(OSX 10.13, *) {
				if let t = self._tooltip {
					segmented.setToolTip(t, forSegment: index)
				}
				else {
					segmented.setToolTip(_title, forSegment: index)
				}
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

		guard let b = self.segmented else {
			fatalError()
		}

		b.translatesAutoresizingMaskIntoConstraints = true
		b.removeConstraints(b.constraints)
	}
}

#endif

// MARK: - Mac Catalyst support

#if targetEnvironment(macCatalyst)

import UIKit

public extension DSFToolbar {
	class Segmented: Core {
		private var segmentedItem: NSToolbarItemGroup?

		override var toolbarItem: NSToolbarItem? {
			return self.segmentedItem
		}

		var segments: [Segment]

		public init(
			_ identifier: NSToolbarItem.Identifier,
			selectionMode: NSToolbarItemGroup.SelectionMode,
			children: [Segment]
		) {
			self.segments = children

			super.init(identifier)

			let items = self.segments.map { $0.makeToolbarItem() }

			let grp = NSToolbarItemGroup(itemIdentifier: identifier)
			grp.subitems = items
			grp.action = #selector(self.groupSelectionChange(_:))
			grp.target = self
			grp.selectionMode = selectionMode

			// For catalyst style apps, make this the default
			grp.isBordered = true

			self.segmentedItem = grp
		}

		public convenience init(
			_ identifier: NSToolbarItem.Identifier,
			selectionMode: NSToolbarItemGroup.SelectionMode,
			_ segments: Segment...
		) {
			self.init(identifier,
						 selectionMode: selectionMode,
						 children: segments.map { $0 })
		}

		/// Called when the control is being destroyed
		override public func close() {
			self._action = nil

			self.segments = []
			self.segmentedItem = nil

			super.close()
		}

		deinit {
			Logging.memory("DSFToolbar.Segmented deinit")
		}

		override public func isBordered(_ state: Bool) -> Self {
			// Do nothing.  For catalyst, segmented control ALWAYS as isBordered
			debugPrint("Calling 'isBordered' on a catalyst segmented control does nothing")
			return self
		}

		// MARK: - Callback action block

		private var _action: ((Set<Int>) -> Void)?

		/// Define the action to call when the selection within the segmented control changes
		/// - Parameter actionBlock: The block to call, passing the selected segment indexes
		/// - Returns: Self
		@discardableResult
		public func action(_ actionBlock: @escaping (Set<Int>) -> Void) -> Segmented {
			self._action = actionBlock
			return self
		}

		@objc private func groupSelectionChange(_: Any) {
			guard let segs = self.segmentedItem else { return }

			let selections = segs.subitems.enumerated().map { segs.isSelected(at: $0.offset) }
			let selIndexes = selections.enumerated().compactMap { $0.element == true ? $0.offset : nil }

			self._selectionBinding?.wrappedValue = NSSet(array: selIndexes)

			self._action?(Set(selIndexes))
		}

		// MARK: - Selection handling

		/// Set the selection mode for the segmented control
		/// - Parameter selectionMode: The mode (select one, select any, momentary etc)
		/// - Returns: self
		public func selectionMode(_ selectionMode: NSToolbarItemGroup.SelectionMode) -> Self {
			self.segmentedItem?.selectionMode = selectionMode
			return self
		}

		// MARK: - Selection bindings

		private var _selectionBinding: ValueBinder<NSSet>?

		/// Bind the selection of the item to a key path (NSSet<Int>)
		/// - Parameters:
		///   - binder: The binding object to connect
		/// - Returns: self
		public func bindSelection(_ selectionBinding: ValueBinder<NSSet>) -> Self {
			self._selectionBinding = selectionBinding
			selectionBinding.register(self) { [weak self] newValue in
				self?.setState(newValue as! Set<Int>)
			}
			self.setState(selectionBinding.wrappedValue as! Set<Int>)
			return self
		}

		/// Set the state for the segmented control
		/// - Parameter state: An array containing the indexes of items to select
		/// - Returns: Self
		@discardableResult
		public func setState(_ state: Set<Int>) -> Self {
			guard let item = self.segmentedItem else { fatalError() }
			item.subitems.enumerated().forEach {
				item.setSelected(state.contains($0.offset),
									  at: $0.offset)
			}
			return self
		}

		override func isEnabledDidChange(to state: Bool) {
			guard let item = self.segmentedItem else { fatalError() }
			item.subitems.enumerated().forEach {
				$0.element.isEnabled = state
			}
		}
	}
}

public extension DSFToolbar.Segmented {
	/// Definition of a segment within a segmented control
	class Segment: NSObject {
		fileprivate var _label = ""
		public func label(_ string: String) -> Segment {
			self._label = string
			return self
		}

		fileprivate var _title = ""
		public func title(_ string: String) -> Segment {
			self._title = string
			return self
		}

		deinit {
			Logging.memory("DSFToolbar.Segmented.Segment deinit")
		}

		// MARK: - Segment image

		fileprivate var _image: DSFImage?
		public func image(_ image: DSFImage) -> Segment {
			self._image = image
			return self
		}

		public func makeToolbarItem() -> NSToolbarItem {
			let item = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(self._label))
			item.image = self._image
			item.title = self._title
			return item
		}
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
