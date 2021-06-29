// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Because Xcode 11 doesn't support soft-links properly
let LegacySources = [
	"../core/utilities.swift",
	"../core/DSFToolbar.View.swift",
	"../core/logging.swift",
	"../core/DSFToolbar.Standard.swift",
	"../core/DSFToolbar.swift",
	"../core/DSFToolbar.PopupButton.swift",
	"../core/DSFToolbar.Search.Core.swift",
	"../core/DSFToolbar.Segmented.swift",
	"../core/DSFToolbar.PopoverButton.swift",
	"../core/DSFToolbar.FunctionBuilder.swift",
	"../core/DSFToolbar.Group.swift",
	"../core/DSFToolbar.Item.swift",
	"../core/DSFToolbar.Core.swift",
	"../core/DSFToolbar.Bindables.swift",
	"../core/DSFToolbar.Button.swift",
	"DSFToolbar.Search.Legacy.swift",
	"DSFToolbar.Separator.Legacy.swift"
]

let package = Package(
	name: "DSFToolbar",
	platforms: [
		.macOS(.v10_11)
	],
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "DSFToolbar",
			type: .static,
			targets: ["DSFToolbar"]),
		.library(
			name: "DSFToolbar-legacy",
			type: .static,
			targets: ["DSFToolbar-legacy"]),
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		// .package(url: /* package url */, from: "1.0.0"),
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "DSFToolbar",
			dependencies: []
		),
		.target(
			name: "DSFToolbar-legacy",
			dependencies: [],
			sources: LegacySources
		),
		.testTarget(
			name: "DSFToolbarTests",
			dependencies: ["DSFToolbar"]),
	]
)
