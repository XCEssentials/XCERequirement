// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "XCERequirement",
    products: [
        .library(
            name: "XCERequirement",
            targets: [
                "XCERequirement"
            ]
        )
    ],
    targets: [
        .target(
            name: "XCERequirement",
            path: "Sources/Core"
        ),
        .testTarget(
            name: "XCERequirementAllTests",
            dependencies: [
                "XCERequirement"
            ],
            path: "Tests/AllTests"
        ),
    ]
)