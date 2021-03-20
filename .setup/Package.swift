// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "RequirementSetup",
    platforms: [
        .macOS(.v10_11),
    ],
    dependencies: [
        .package(
            name: "PathKit",
            url: "https://github.com/kylef/PathKit",
            from: "1.0.0"
        ),
        .package(
            name: "XCERepoConfigurator",
            url: "https://github.com/XCEssentials/RepoConfigurator",
            from: "3.0.0"
        )
    ],
    targets: [
        .target(
            name: "RequirementSetup",
            dependencies: [
                "XCERepoConfigurator",
                "PathKit"
            ],
            path: "Setup"
        )
    ]
)
