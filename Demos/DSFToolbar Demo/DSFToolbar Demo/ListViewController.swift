//
//  ListViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 29/9/20.
//

import Cocoa

class ListViewController: NSViewController {

	@IBOutlet weak var demoTableView: NSTableView!

	@IBOutlet weak var propertiesViewController: PropertiesViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension ListViewController: NSTableViewDataSource, NSTableViewDelegate {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return DemoContent.count
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let v = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("ListItem"), owner: self) as? NSTableCellView else {
			assert(false)
			return nil
		}

		v.textField?.stringValue = DemoContent.allNames[row]
		return v
	}

	func tableViewSelectionDidChange(_ notification: Notification) {
		let row = self.demoTableView.selectedRow

		var name = ""
		if row != -1 {
			name = DemoContent.allNames[row]
		}
		propertiesViewController.selectedName(name: name)
	}
}
