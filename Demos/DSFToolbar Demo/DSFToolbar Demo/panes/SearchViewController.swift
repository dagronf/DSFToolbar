//
//  SearchViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 30/9/20.
//

import Cocoa
import DSFToolbar

import DSFValueBinders

class SearchViewController: NSViewController {
	var toolbarContainer: DSFToolbar?

	let searchDebounce = DSFDebounce(seconds: 0.25)

	@IBOutlet var searchFieldContent: NSTextField!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do view setup here.

		self.build()
	}

	@objc dynamic var searchEnabled: Bool = true
	lazy var searchEnabledBinder = try! KeyPathBinder(self, keyPath: \.searchEnabled)

	@objc dynamic var searchButtonLabel: String = "Enabled"


	@objc dynamic var searchText: String = ""
	lazy var searchTextBinder = try! KeyPathBinder(self, keyPath: \.searchText)

	func build() {
		
		self.toolbarContainer = DSFToolbar(
			toolbarIdentifier: NSToolbar.Identifier("primary-search"),
			allowsUserCustomization: true
		) {
			DSFToolbar.Button(NSToolbarItem.Identifier("enabler"))
				.width(minVal: 80)
				.buttonType(.pushOnPushOff)
				//.bezelStyle(.regularSquare)
				.image(ProjectAssets.Image.toolbar_search_enable.image)
				.imageScaling(.scaleProportionallyDown)
				.bindLabel(try! KeyPathBinder(self, keyPath: \.searchButtonLabel))
				.bindOnOffState(searchEnabledBinder)
				.legacySizes(minSize: NSSize(width: 80, height: 63))

			DSFToolbar.Button(NSToolbarItem.Identifier("hardcode-string"))
				.width(minVal: 80)
				.bindIsEnabled(searchEnabledBinder)
				.buttonType(.momentaryLight)
				//.bezelStyle(.regularSquare)
				.image(ProjectAssets.Image.toolbar_search_hardcode.image)
				.imageScaling(.scaleProportionallyDown)
				.legacySizes(minSize: NSSize(width: 80, height: 63))
				.label("Hardcode")
				.action { [weak self] _ in
					self?.searchText = "Hardcoded"
				}

			DSFToolbar.FlexibleSpace()

			DSFToolbar.Search(NSToolbarItem.Identifier("search-field"))
				.label("Search for stuff")
				.bindIsEnabled(searchEnabledBinder)
				.bindSearchText(searchTextBinder)
				.onSearchTextChange { [weak self] _, text in
					self?.searchDebounce.debounce {
						Swift.print("Search text is now '\(text)'")
					}
				}
		}
	}
}

extension SearchViewController: NSSearchFieldDelegate {
	func searchFieldDidStartSearching(_: NSSearchField) {
		Swift.print("searchFieldDidStartSearching")
	}

	func searchFieldDidEndSearching(_: NSSearchField) {
		Swift.print("searchFieldDidEndSearching")
	}

	func controlTextDidChange(_ obj: Notification) {
		if let s = obj.object as? NSSearchField {
			let text = s.stringValue
			self.searchDebounce.debounce {
				Swift.print("Search text is now '\(text)'")
			}
		}
	}
}

extension SearchViewController: DemoContentViewController {
	static func Create() -> NSViewController {
		return SearchViewController()
	}

	static func Title() -> String {
		return "Search"
	}

	var customToolbar: DSFToolbar? {
		return self.toolbarContainer
	}

	func cleanup() {
		self.toolbarContainer?.close()
		self.toolbarContainer = nil
	}
}
