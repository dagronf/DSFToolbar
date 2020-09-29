//
//  DemoContentContainer.swift
//  DSFTouchBar Demo
//
//  Created by Darren Ford on 10/9/20.
//

import AppKit

import DSFToolbar

let DemoContent = DemoContentContainer()

protocol DemoContentViewController {
	static func Create() -> NSViewController
	static func Title() -> String

	var customToolbar: DSFToolbar? { get }

	func cleanup()
}

class DemoContentContainer {

	var allContent = [(String, DemoContentViewController.Type)]()

	var count: Int {
		return allContent.count
	}

	var allNames: [String] {
		return allContent.map { $0.0 }.sorted()
	}

	init() {
		self.setup()
	}

	func add<T>(_ item: T.Type) where T: DemoContentViewController {
		self.allContent.append( (T.Title(), T.self) )
	}

	func setup() {
		self.add(ImagesViewController.self)
		self.add(SegmentedViewController.self)
		self.add(ButtonViewController.self)
		self.add(SearchViewController.self)
		self.add(SeparatorViewController.self)

		self.allContent.sort { (l1, r1) -> Bool in
			return l1.0 < r1.0
		}
	}

	func controller(for title: String) -> NSViewController? {
		guard let item = allContent.filter({ $0.0 == title }).first else {
			return nil
		}
		return item.1.Create()
	}

}
