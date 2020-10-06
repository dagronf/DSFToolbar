
import Dispatch
import Foundation

internal class DSFDebounce {
	// MARK: - Properties

	private let queue = DispatchQueue.main
	private var workItem = DispatchWorkItem(block: {})
	private var interval: TimeInterval

	// MARK: - Initializer

	init(seconds: TimeInterval) {
		self.interval = seconds
	}

	// MARK: - Debouncing function

	func debounce(action: @escaping (() -> Void)) {
		workItem.cancel()
		workItem = DispatchWorkItem(block: { action() })
		queue.asyncAfter(deadline: .now() + interval, execute: workItem)
	}
}
