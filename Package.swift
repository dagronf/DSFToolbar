// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "DSFToolbar",
	platforms: [
		.macOS(.v10_12)
	],
	products: [
		.library(name: "DSFToolbar", targets: ["DSFToolbar"]),
		.library(name: "DSFToolbar-static", type: .static, targets: ["DSFToolbar"]),
		.library(name: "DSFToolbar-shared", type: .dynamic, targets: ["DSFToolbar"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/DSFValueBinders", from: "0.7.3")
	],
	targets: [
		.target(
			name: "DSFToolbar",
			dependencies: ["DSFValueBinders"]
		),
		.testTarget(
			name: "DSFToolbarTests",
			dependencies: ["DSFToolbar"]),
	]
)
