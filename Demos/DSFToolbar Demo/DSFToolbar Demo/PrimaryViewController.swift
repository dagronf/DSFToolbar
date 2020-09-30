//
//  PrimaryViewController.swift
//  DSFToolbar Demo
//
//  Created by Darren Ford on 29/9/20.
//

import Cocoa

import DSFToolbar

class PrimaryViewController: NSViewController {
	@IBOutlet weak var scrollView: NSScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do view setup here.
		scrollView.automaticallyAdjustsContentInsets = true
    }
   
}
