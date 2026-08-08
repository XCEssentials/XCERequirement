// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "XCERequirement",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "XCERequirement",
            targets: [
                "XCERequirement"
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/SimplyDanny/SwiftLintPlugins",
            exact: "0.65.0"
        )
    ],
    targets: [
        .target(
            name: "XCERequirement",
            path: "Sources/Core",
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLintPlugins"
                )
            ]
        ),
        .testTarget(
            name: "XCERequirementAllTests",
            dependencies: [
                "XCERequirement"
            ],
            path: "Tests/AllTests",
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLintPlugins"
                )
            ]
        )
    ]
)
