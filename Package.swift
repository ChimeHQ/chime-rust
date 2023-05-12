// swift-tools-version: 5.6

import PackageDescription

let package = Package(
	name: "chime-rust",
	platforms: [.macOS(.v11)],
	products: [
		.library(name: "ChimeRust", targets: ["ChimeRust"]),
	],
	dependencies: [
		.package(url: "https://github.com/ChimeHQ/ChimeKit", from: "0.2.0"),
	],
	targets: [
		.target(name: "ChimeRust", dependencies: ["ChimeKit"]),
		.testTarget(name: "ChimeRustTests", dependencies: ["ChimeRust"]),
	]
)
