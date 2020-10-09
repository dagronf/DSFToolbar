//
//  logging.swift
//  DSFToolbar
//
//  Basic logging framework for DSFToolbar
//  Created by Darren Ford on 5/10/20.
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

import Foundation

import os

// See https://www.avanderlee.com/workflow/oslog-unified-logging/

extension OSLog {
	private static var subsystem = Bundle.main.bundleIdentifier!

	/// Logs the view cycles like viewDidLoad.

	@available(OSX 10.12, iOS 10.0, *)
	static let memoryAlloc = OSLog(subsystem: subsystem, category: "memory")
}

class Logging {

	/// Function for tracking memory and memory related events
	static func memory(_ msg: StaticString, args: CVarArg...) {
		if #available(OSX 10.12, iOS 10.0, *) {
			os_log(msg, log: OSLog.memoryAlloc, type: .debug, args)
		}
		else {
			// Fallback on earlier versions
			debugPrint(msg)
		}
	}
}
