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

		public class Segment: NSObject {


			var index: Int = -1
			weak var parent: Segmented? = nil

			var _title: String = ""
			func title(_ string: String) -> Segment {
				self._title = string
				return self
			}

			private var _image: NSImage?
			private var _imageScaling: NSImageScaling = .scaleProportionallyUpOrDown
			func image(_ image: NSImage, scaling: NSImageScaling = .scaleProportionallyUpOrDown) -> Segment {
				self._image = image
				self._imageScaling = scaling
				return self
			}


			//// Enabled

			var _bindingEnabledObject: AnyObject? = nil
			var _bindingEnabledKeyPath: String? = nil

			func bindEnabled(_ object: AnyObject, keyPath: String) -> Self {
				_bindingEnabledObject = object
				_bindingEnabledKeyPath = keyPath
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
			func onCreate(parent: Segmented, index: Int) {
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

				if let o = self._bindingEnabledObject,
				   let k = self._bindingEnabledKeyPath {
					o.addObserver(self, forKeyPath: k, options: [.new], context: nil)

					/// Set an initial value
					if let v = o.value(forKeyPath: k) as? Bool {
						segmented.setEnabled(v, forSegment: index)
					}
				}
			}

			func close() {
				if let o = self._bindingEnabledObject,
				   let k = self._bindingEnabledKeyPath {
					o.removeObserver(self, forKeyPath: k)
				}
			}

			override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
				if _bindingEnabledKeyPath == keyPath,
				  let newVal = change?[.newKey] as? Bool {
					parent?.segmented?.setEnabled(newVal, forSegment: self.index)
				}
				else {
					super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
				}
			}

		}

		public enum SegmentedType {
			case Separated
			case Grouped
		}

		private var segmented: NSSegmentedControl?
		private var segmentedItem: NSToolbarItem?

		override var toolbarItem: NSToolbarItem? {
			return self.segmentedItem
		}

		let segments: [Segment]

		init(_ identifier: NSToolbarItem.Identifier,
			 type: SegmentedType,
			 switching: NSSegmentedControl.SwitchTracking = .selectAny,
			 _ segments: Segment...) {

			self.segments = segments.map { $0 }

			super.init(identifier)

			let s = NSSegmentedControl(frame: .zero)
			s.translatesAutoresizingMaskIntoConstraints = false
			s.trackingMode = switching

			if #available(OSX 10.13, *) {
				s.segmentDistribution = .fillEqually
			} else {
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
				seg.element.onCreate(parent: self, index: seg.offset)
			}

			let a = NSToolbarItem(itemIdentifier: self.identifier)
			a.view = s
			self.segmentedItem = a
		}

		////// Item action callbacks

		var _action: ((Set<Int>) -> Void)?
		func action(_ block: @escaping (Set<Int>) -> Void) -> Segmented {
			self._action = block
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

			if let o = _bindingSelectionObject,
			   let k = _bindingSelectionKeyPath {
				o.setValue(NSSet(array: selected), forKey: k)
			}

			self._action?(Set(selected))
		}

		///// Selection bindings

		var _bindingSelectionObject: AnyObject?
		var _bindingSelectionKeyPath: String?
		public func bindSelection(_ object: AnyObject, keyPath: String) -> Self {
			_bindingSelectionObject = object
			_bindingSelectionKeyPath = keyPath
			object.addObserver(self, forKeyPath: keyPath, options: [.new], context: nil)
			if let v = object.value(forKeyPath: keyPath) as? NSSet {
				self.setSelection(selectedItems: v)
			}
			return self
		}

		func setSelection(selectedItems: NSSet) {
			guard let s = self.segmented,
				  let sels = selectedItems as? Set<Int> else {
				fatalError()
			}

			self.segments.enumerated().forEach { segment in
				s.setSelected(sels.contains(segment.offset), forSegment: segment.offset)
			}
		}

		///// OBSERVER

		override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
			if _bindingSelectionKeyPath == keyPath,
			  let newVal = change?[.newKey] as? NSSet {
				self.setSelection(selectedItems: newVal)
			}
			else {
				super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
			}
		}



		///// Cleanup

		override public func close() {
			self._action = nil

			self.segments.forEach { $0.close() }

			if let o = _bindingSelectionObject,
			   let k = _bindingSelectionKeyPath{
				o.removeObserver(self, forKeyPath: k)
				_bindingSelectionObject = nil
			}

			self.segmented?.target = nil
			self.segmented = nil

			self.segmentedItem?.view = nil
			self.segmentedItem = nil

			super.close()
		}

		deinit {
			debugPrint("DSFToolbar.Segmented deinit")
		}
	}
}
