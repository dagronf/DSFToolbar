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

		private var _segmentEnabledBinding: ValueBinder<IndexSet>?

		/// Create a segmented toolbar item
		/// - Parameters:
		///   - identifier: The item identifier
		///   - selectionMode: The selection mode for the segmented item
		///   - children: The segments
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
			self.init(
				identifier,
				selectionMode: selectionMode,
				children: segments.map { $0 }
			)
		}

		/// Called when the control is being destroyed
		override public func close() {
			self._actionBlock = nil

			self.segments = []
			self.segmentedItem = nil

			super.close()
		}

		deinit {
			self._selectionBinding?.deregister(self)
			self._segmentEnabledBinding?.deregister(self)
			self._actionBlock = nil
			Logging.memory("DSFToolbar.Segmented(%@) deinit", args: self.identifier.rawValue)
		}

		override public func isBordered(_ state: Bool) -> Self {
			// Do nothing.  For catalyst, segmented control ALWAYS as isBordered
			return self
		}

		// MARK: - Callback action block

		private var _actionBlock: ((IndexSet) -> Void)?

		/// Define the action to call when the selection within the segmented control changes
		/// - Parameter actionBlock: The block to call, passing the selected segment indexes
		/// - Returns: Self
		@discardableResult
		public func action(_ actionBlock: @escaping (IndexSet) -> Void) -> Segmented {
			self._actionBlock = actionBlock
			return self
		}

		/// The control's selected items
		fileprivate func selected() -> IndexSet {
			guard let segs = self.segmentedItem else { return IndexSet() }
			let sels = segs.subitems.enumerated()
				.compactMap { segs.isSelected(at: $0.offset) ? $0.offset : nil }
			return IndexSet(sels)
		}

		// MARK: - Selection change

		/// Called when the segmented control selection changes
		@objc private func groupSelectionChange(_: Any) {
			// The currently selected indexes
			let indexes = self.selected()

			// Update the selection binding if it exists
			self._selectionBinding?.wrappedValue = indexes
			// Call the action block if it exists
			self._actionBlock?(indexes)
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

		private var _selectionBinding: ValueBinder<IndexSet>?

		/// Bind the selection of the item to a key path (IndexSet)
		/// - Parameters:
		///   - binder: The binding object to connect
		/// - Returns: self
		public func bindSelection(_ selectionBinding: ValueBinder<IndexSet>) -> Self {
			self._selectionBinding = selectionBinding
			selectionBinding.register(self) { [weak self] newValue in
				self?.setState(newValue)
			}
			return self
		}

		/// Set the state for the segmented control
		/// - Parameter state: An array containing the indexes of items to select
		/// - Returns: Self
		@discardableResult
		public func setState(_ state: IndexSet) -> Self {
			guard let item = self.segmentedItem else { fatalError() }
			item.subitems.enumerated().forEach {
				item.setSelected(state.contains($0.offset), at: $0.offset)
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
	/// Bind the current selection of the segmented control (IndexSet)
	/// - Parameters:
	///   - binder: The binding object to connect
	/// - Returns: self
	func bindSegmentEnabled(_ segmentEnabledBinding: ValueBinder<IndexSet>) -> Self {
		self._segmentEnabledBinding = segmentEnabledBinding
		segmentEnabledBinding.register(self) { [weak self] newValue in
			self?.setSegmentEnabledState(newValue)
		}
		return self
	}

	private func setSegmentEnabledState(_ indexes: IndexSet) {
		guard let item = self.segmentedItem else { fatalError() }
		item.subitems.enumerated().forEach {
			$0.element.isEnabled = indexes.contains($0.offset)
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
