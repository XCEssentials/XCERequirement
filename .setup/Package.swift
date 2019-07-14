// swift-tools-version:5.0
// Managed by ice

import PackageDescription

let package = Package(
    name: "RequirementSetup",
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit", from: "1.0.0"),
        .package(url: "https://github.com/XCEssentials/RepoConfigurator", from: "2.7.0")
    ],
    targets: [
        .target(
            name: "RequirementSetup",
            dependencies: ["XCERepoConfigurator", "PathKit"],
            path: ".",
            sources: ["main.swift"]
        )
    ]
)
