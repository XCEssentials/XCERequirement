// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "XCERequirement",
    platforms: [
        .macOS(.v12),
        .macCatalyst(.v15),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
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
    ],
    swiftLanguageModes: [.v6]
)
