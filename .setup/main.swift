import PathKit

import XCERepoConfigurator

// MARK: - PRE-script invocation output

print("\n")
print("--- BEGIN of '\(Executable.name)' script ---")

// MARK: -

// MARK: Parameters

Spec.BuildSettings.swiftVersion.value = "5.0"
let swiftLangVersions = "[.v5]"

let localRepo = try Spec.LocalRepo.current()

let remoteRepo = try Spec.RemoteRepo(
    accountName: localRepo.context,
    name: localRepo.name
)

let travisCI = (
    address: "https://travis-ci.com/\(remoteRepo.accountName)/\(remoteRepo.name)",
    branch: "master"
)

let company = try Spec.Company(
    prefix: "XCE",
    name: remoteRepo.accountName
)

let project = try Spec.Project(
    name: remoteRepo.name,
    summary: "Describe requirements in a declarative, easy-readable format",
    copyrightYear: 2016,
    deploymentTargets: [
        .iOS : "9.0",
        .watchOS : "3.0", // be prepared to fail 'pod lib lint' if uncomment!
        .tvOS : "9.0",
        .macOS : "10.11"
    ]
)

let product = (
    name: company.prefix + project.name,
    bundleId: "com.\(remoteRepo.accountName).\(remoteRepo.name)"
)

let authors = [
    ("Maxim Khatskevich", "maxim@khatskevi.ch")
]

typealias PerSubSpec<T> = (
    core: T,
    tests: T
)

let cocoaPodsSubSpecs: PerSubSpec = (
    Spec.CocoaPod.SubSpec("Core"),
    Spec.CocoaPod.SubSpec.tests()
)

let subSpecs: PerSubSpec = (
    cocoaPodsSubSpecs.core.name,
    cocoaPodsSubSpecs.tests.name
)

let targetNames: PerSubSpec = (
    product.name,
    product.name + subSpecs.tests
)

let sourcesLocations: PerSubSpec = (
    Spec.Locations.sources + subSpecs.core,
    Spec.Locations.tests + subSpecs.tests
)

let swiftPMPackageManifestFileName = "Package.swift"
let prepareForCarthageXcconfigFileName = "PrepareForCarthage.xcconfig"
let prepareForCarthageShFileName = "PrepareForCarthage.sh"

let license: CocoaPods.Podspec.License = (
    License.MIT.licenseType,
    License.MIT.relativeLocation
)

var cocoaPod = try Spec.CocoaPod(
    companyInfo: .from(company),
    productInfo: .from(project),
    authors: authors
)

try? cocoaPod.readCurrentVersion()

// MARK: Parameters - Summary

localRepo.report()
remoteRepo.report()

// MARK: -

// MARK: Write - ReadMe

try ReadMe()
    .addGitHubLicenseBadge(
        account: company.name,
        repo: project.name
    )
    .addGitHubTagBadge(
        account: company.name,
        repo: project.name
    )
    .addSwiftPMCompatibleBadge()
    .addWrittenInSwiftBadge(
        version: Spec.BuildSettings.swiftVersion.value
    )
    .addStaticShieldsBadge(
        "platforms",
        status: "macOS | iOS | tvOS | watchOS | Linux",
        color: "blue",
        title: "Supported platforms",
        link: "Package.swift"
    )
    .add("""
        [![Build Status](\(travisCI.address).svg?branch=\(travisCI.branch))](\(travisCI.address))
        """
    )
    .add("""

        # \(project.name)

        \(project.summary)

        """
    )
    .prepare(
        removeRepeatingEmptyLines: false
    )
    .writeToFileSystem(
        ifFileExists: .skip
    )

// MARK: Write - License

try License
    .MIT(
        copyrightYear: UInt(project.copyrightYear),
        copyrightEntity: authors.map{ $0.0 }.joined(separator: ", ")
    )
    .prepare()
    .writeToFileSystem()

// MARK: Write - GitHub - PagesConfig

try GitHub
    .PagesConfig()
    .prepare()
    .writeToFileSystem()

// MARK: Write - Git - .gitignore

try Git
    .RepoIgnore()
    .addMacOSSection()
    .addCocoaSection()
    .addSwiftPackageManagerSection(ignoreSources: true)
    .add(
        """
        # we don't need to store project file,
        # as we generate it on-demand
        *.\(Xcode.Project.extension)
        .vendor
        """
    )
    .prepare()
    .writeToFileSystem()

// MARK: Write - Bundler - Gemfile

// https://docs.fastlane.tools/getting-started/ios/setup/#use-a-gemfile
try Bundler
    .Gemfile(
        basicFastlane: false,
        """
        gem '\(CocoaPods.gemName)'
        gem '\(CocoaPods.Generate.gemName)'
        """
    )
    .prepare()
    .writeToFileSystem()

// MARK: Write - CocoaPods - Podspec

try CocoaPods
    .Podspec
    .withSubSpecs(
        project: project,
        company: cocoaPod.company,
        version: cocoaPod.currentVersion,
        license: license,
        authors: cocoaPod.authors,
        swiftVersion: Spec.BuildSettings.swiftVersion.value,
        globalSettings: {
            
            globalContext in
            
            //declare support for all defined deployment targets
            
            project
                .deploymentTargets
                .forEach{ globalContext.settings(for: $0) }
        },
        subSpecs: {

            let core = cocoaPodsSubSpecs.core
            
            $0.subSpec(core.name){

                $0.settings(
                    .sourceFiles(core.sourcesPattern)
                )
            }
        },
        testSubSpecs: {
            
            let tests = cocoaPodsSubSpecs.tests

            $0.testSubSpec(tests.name){

                $0.settings(
                    .noPrefix("requires_app_host = false"),
                    .sourceFiles(tests.sourcesPattern)
                )
            }
        }
    )
    .prepare(
        for: cocoaPod
    )
    .writeToFileSystem()

// MARK: Write - Package.swift

try CustomTextFile("""
    // swift-tools-version:\(Spec.BuildSettings.swiftVersion.value)

    import PackageDescription

    let package = Package(
        name: "\(product.name)",
        products: [
            .library(
                name: "\(product.name)",
                targets: [
                    "\(targetNames.core)"
                ]
            )
        ],
        targets: [
            .target(
                name: "\(targetNames.core)",
                path: "\(sourcesLocations.core)"
            ),
            .testTarget(
                name: "\(targetNames.tests)",
                dependencies: [
                    "\(targetNames.core)"
                ],
                path: "\(sourcesLocations.tests)"
            ),
        ],
        swiftLanguageVersions: \(swiftLangVersions)
    )
    """
    )
    .prepare(
        at: [swiftPMPackageManifestFileName]
    )
    .writeToFileSystem()

// MARK: Write - PrepareForCarthage.xcconfig

try CustomTextFile("""
    PRODUCT_BUNDLE_IDENTIFIER = "\(product.bundleId)"
    CURRENT_PROJECT_VERSION = 1
    VERSIONING_SYSTEM = "apple-generic"
    """
    )
    .prepare(
        at: [prepareForCarthageXcconfigFileName]
    )
    .writeToFileSystem()

// MARK: Write - PrepareForCarthage.sh

try CustomTextFile("""
    #!/bin/bash
    # http://www.grymoire.com/Unix/Sed.html#TOC

    currentVersion=$1

    #---

    productName="\(product.name)"
    bundleId="\(product.bundleId)"

    xcconfigFile="\(prepareForCarthageXcconfigFileName)"

    #---

    echo "ℹ️ Preparing $productName for Carthage."

    echo "Updating xcconfig file with version $currentVersion..."
    sed -i '' -e "s|^CURRENT_PROJECT_VERSION = .*$|CURRENT_PROJECT_VERSION = $currentVersion|g" $xcconfigFile

    echo "Generating project file using SwiftPM and config file $xcconfigFile"
    swift package generate-xcodeproj --xcconfig-overrides $xcconfigFile

    # NOTE: the xcconfig file will be applied to all dependency targets as well,
    # but it's not an issue in this case.

    echo "Overriding PRODUCT_BUNDLE_IDENTIFIER with <$bundleId> in project file due to bug in SwiftPM."
    # SwiftPM overrides this value even after applying custom xcconfig file.
    sed -i '' -e "s|PRODUCT_BUNDLE_IDENTIFIER = \\"$productName\\"|PRODUCT_BUNDLE_IDENTIFIER = $bundleId|g" $productName.xcodeproj/project.pbxproj

    echo "ℹ️ Done"
    
    """
    )
    .prepare(
        at: [prepareForCarthageShFileName]
    )
    .writeToFileSystem()

// MARK: - POST-script invocation output

print("--- END of '\(Executable.name)' script ---")
