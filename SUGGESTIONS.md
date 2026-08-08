# Suggestions for the next major release

Reviewed on 2026-08-08 against the current repository and Swift 6.2.4. The
existing 14 XCTest tests pass. Swift 6.3 is the latest stable Swift release;
Swift 6.4 has been announced but is not yet a stable release, so it should not
be the release baseline.

## Recommended release direction

Keep the library small and dependency-free, but use the major version to make
its error model, concurrency contract, and naming coherent. A good target is:

- require Swift 6.0 and compile the target in Swift 6 language mode;
- keep compatibility testing on the oldest supported toolchain (6.0), then add
  current stable Swift (currently 6.3) on macOS and Linux;
- make source locations and errors first-class value types;
- separate a nonthrowing predicate from a throwing evaluation, or clearly model
  the distinction in the result/error API;
- add small composition and `callAsFunction` conveniences before considering a
  large result-builder DSL.

## P0 — settle before releasing

### 1. Keep Swift 6 language mode enabled

The package now requires Swift tools version 6.0 and explicitly compiles in
Swift 6 language mode. Keep both settings in place for the next major release:

```swift
// swift-tools-version: 6.0

let package = Package(
    name: "XCERequirement",
    // ...
    swiftLanguageModes: [.v6]
)
```

Build with warnings treated as errors in CI and run both debug and release
builds. The official [Swift 6 migration guide](https://www.swift.org/migration/)
explains that Swift 6 mode enables required data-race checks and is opt-in per
target. If an intermediate 5.x release is desired first, enable complete
strict-concurrency checking there and fix warnings before changing the language
mode, following the guide's [migration strategy](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/migrationstrategy/).

### 2. Define the predicate failure semantics

`Requirement.Body` is `(Input) throws -> Bool`, but the public operations give
three different interpretations:

- `validate` propagates an evaluation error unchanged;
- `isValid` catches every error and returns `false`, making “not satisfied” and
  “could not evaluate” indistinguishable;
- `Check.that` wraps evaluation errors in `FailedCheck`.

This is the largest API ambiguity in the package. Choose and document one model.
The clearest major-version design is to make ordinary `Requirement` predicates
nonthrowing and offer an explicitly named throwing/evaluated variant. A smaller
change is to add `evaluate(_:) -> Result<Void, RequirementError>` and make
`isSatisfied(by:)` nonthrowing only when its predicate is nonthrowing. Avoid a
Boolean API that silently converts arbitrary failures to `false`.

Typed throws (SE-0413, available in Swift 6) can improve exhaustive handling,
but only if the predicate's failure type is represented in the generic model.
Do not merely declare `throws(UnsatisfiedRequirement)`: the stored closure can
currently throw any error. A possible, deliberately explicit shape is:

```swift
public enum RequirementError<Input, EvaluationFailure: Error>: Error {
    case unsatisfied(input: Input, source: SourceLocation)
    case evaluationFailed(EvaluationFailure, source: SourceLocation)
}
```

This is more type-safe but adds a second generic parameter, so prototype it and
compare call-site ergonomics before committing. Untyped `throws` plus a stable
wrapper error is preferable to a cumbersome public type.

### 3. Replace context tuples with a source-location value

The same `(file: String, line: Int, function: String)` tuple is repeated in both
error types. Tuples cannot gain useful conformances and the current `#file`
default exposes full build-machine paths. Introduce one public type:

```swift
public struct SourceLocation: Sendable, Hashable, Codable {
    public let fileID: String
    public let line: UInt
    public let function: String

    public init(
        fileID: String = #fileID,
        line: UInt = #line,
        function: String = #function
    ) { /* ... */ }
}
```

Then accept `source: SourceLocation = .init()` at API boundaries. This shortens
every signature, makes diagnostics testable/serializable, and avoids leaking
absolute paths. If full paths are genuinely required, expose a separately named
opt-in initializer using `#filePath`.

### 4. Redesign errors as useful diagnostics

- Give `UnsatisfiedRequirement` and `FailedCheck` `CustomStringConvertible`
  and `LocalizedError` conformances so `print(error)` and UI presentation match
  the README's promise.
- Prefer a consistent case vocabulary such as `unsatisfied` and
  `evaluationFailed`; `unsatisfiedNonEmptyCondition` is overly specialized.
- Consider one `RequirementFailure<Input>` rather than storing `input: Any`.
  `Any` forces casts, erases type safety, blocks useful `Sendable` conformance,
  and may retain or log sensitive input. If a non-generic error is important,
  store an optional redacted/debug snapshot instead and let callers opt in.
- Decide and test whether nested errors remain available as `underlyingError`.
- Add explicit public initializers where users are expected to construct these
  values; do not rely on internal synthesized memberwise initializers.

### 5. Make the concurrency contract explicit

`Requirement` is an immutable value but stores an unconstrained escaping
closure, so it is not safely transferable between tasks. For a Swift 6-native
API, consider:

```swift
public typealias Body = @Sendable (Input) throws -> Bool
public struct Requirement<Input>: Sendable { /* ... */ }
```

This is source-breaking because captured mutable/non-`Sendable` state will no
longer compile—which is appropriate to assess in a major release. Do not use
`@unchecked Sendable`. Also make source locations and any redesigned failures
`Sendable` where their stored values permit it. The underlying rules are
described by [SE-0302](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md).

This library should remain nonisolated rather than adopt Swift 6.2's optional
main-actor default: validation is general-purpose, synchronous work and must be
usable from any actor. Swift 6.2's approachable-concurrency changes are useful
for applications, but default main-actor isolation would be harmful here; see
the [Swift 6.2 release notes](https://www.swift.org/blog/swift-6.2-released/).

## P1 — improve API clarity and developer experience

### 6. Use names that read naturally

Suggested surface:

```swift
requirement.isSatisfied(by: value)
try requirement.validate(value)
try Check.require(value > 0, "Value must be positive")
let value = try Check.unwrap(optional, "Value must exist")
```

- Rename `isValid` to `isSatisfied(by:)`: the requirement is not what becomes
  valid; an input satisfies it.
- Rename `Check.that` to `require` (or keep `that` as a deprecated forwarding
  overload for one release).
- Rename `nonEmpty` to `unwrap` or `nonNil`. “Empty” normally also describes an
  empty collection/string, while this function checks only `Optional.none`.
- Put the value/expression first and the prose second where it improves trailing
  closure and autocomplete behavior.
- Use `@autoclosure` for the simple Boolean/optional overloads so evaluation
  remains lazy without braces; retain closure overloads for throwing work.

Use `@available(*, deprecated, renamed: ...)` shims and include a migration
table in the release notes.

### 7. Make a requirement callable

`callAsFunction` is a small, idiomatic way to reduce ceremony without inventing
a DSL:

```swift
public func callAsFunction(_ input: Input) throws {
    try validate(input)
}

try isAdult(user)
```

If both Boolean and throwing call forms are desirable, do not overload solely
by return type. Pick one behavior for `callAsFunction`; keep the other explicitly
named.

### 8. Add principled composition

The README currently says requirements containing AND/OR “should” be split,
but splitting and composing are complementary. Add named combinators first:

```swift
let eligible = isAdult.and(hasConsent)
let recognized = isEmail.or(isPhoneNumber)
let forbidden = isBlocked.negated()
```

Define short-circuiting, thrown-error propagation, description formatting, and
source-location behavior. Operators (`&&`, `||`, prefix `!`) can be added later
only if they remain obvious in documentation and diagnostics.

### 9. Add collections of requirements before a result-builder DSL

An additive batch API gives most of the declarative benefit with little magic:

```swift
let failures = requirements.failures(for: user)
try requirements.validateAll(user)
```

Specify fail-fast versus accumulation explicitly and preserve each requirement's
description. A result builder could then be a thin syntax layer:

```swift
let accountRules = Requirements<Account> {
    Requirement("Email is present") { !$0.email.isEmpty }
    if requiresConsent {
        Requirement("Consent is granted") { $0.hasConsent }
    }
}
```

Only add this after the underlying collection/reporting model is stable. For a
library this small, a macro dependency would materially increase build time and
maintenance; result builders require no plugin and are the better first choice.

### 10. Add concise factories for common predicates

Key-path and `Comparable` helpers can make definitions declarative while staying
strongly typed, for example `Requirement.equals(\.status, .active, description:)`,
`.nonNil(\.owner)`, and `.contains(\.roles, .admin)`. Keep the core generic and
add only helpers backed by repeated real-world call sites. Avoid a broad catalog
that duplicates the standard library.

## P1 — package quality and CI

### 11. Expand the test strategy

- Migrate to Swift Testing for parameterized cases and clearer `#expect`/
  `#require` diagnostics, or run it alongside XCTest while Swift 6.0 is the
  minimum. Swift 6.3 adds further Swift Testing improvements, summarized in the
  [Swift 6.3 release notes](https://www.swift.org/blog/swift-6.3-released/).
- Test exact source propagation for every public entry point, underlying thrown
  errors, default descriptions, all composition truth tables, short-circuiting,
  and concurrency/sendability compile checks.
- Rename `test_nonEmpty_successs` and use consistent modern test names.
- Add a small executable/fixture client compiled in Swift 6 mode. Tests inside
  the package do not catch every public-access or external type-inference issue.
- Run `swift test --parallel`, `swift build -c release`, and a warning-free Swift
  6 build in CI.
- Generate coverage and establish a sensible threshold for this tiny package.

### 12. Correct and broaden the CI matrix

The current matrix labels Swift versions independently of the runner but relies
on a setup action to make every combination work. For the release:

- test the minimum Swift 6.0 toolchain and latest stable Swift 6.3;
- retain macOS and Ubuntu, and consider Windows because the package uses only
  the standard library;
- add an Apple-platform build matrix for iOS, tvOS, watchOS, and visionOS if the
  README continues claiming Apple-platform support;
- pin third-party actions to commit SHAs for supply-chain hardening;
- add concurrency sanitizer/Thread Sanitizer coverage only if asynchronous or
  shared-state functionality is introduced.

Swift 6.3 also ships an official Android SDK, but do not claim Android support
until it is built in CI. The package is a plausible candidate because it has no
Foundation or Apple-framework dependency.

### 13. Decide platform policy explicitly

`Package.swift` declares no minimum platforms, while the badge claims macOS,
iOS, tvOS, watchOS, and Linux. Either keep the package platform-agnostic and
state “platforms supported by the tested Swift toolchains,” or declare minimum
Apple versions and test them. Also add visionOS, Windows, Android, or WebAssembly
only after verification. Avoid unnecessary minimum-version declarations: the
current standard-library-only implementation has no deployment-sensitive API.

### 14. Add release engineering basics

- Add `CHANGELOG.md` with a migration section for source-breaking changes.
- Add a DocC catalog and documentation comments for every public symbol;
  validate documentation in CI.
- Consider an API-digester/symbol-graph check so accidental public API breaks
  are caught after the major release.
- Add `CONTRIBUTING.md`, a supported-Swift policy, and a release checklist.
- If tags are distributed publicly, document semantic-versioning expectations.

## P2 — repository cleanup

### 15. Modernize layout and formatting

- Move sources to the conventional `Sources/XCERequirement/` and tests to
  `Tests/XCERequirementTests/`; then remove custom `path` entries from the
  manifest.
- Rename `AllTests.swift` to files grouped by subject.
- Adopt standard Swift formatting consistently. The current split declaration
  modifiers and Allman-style braces create much more vertical noise than the
  implementation warrants.
- Replace the full MIT header in every source file with a concise SPDX identifier
  such as `// SPDX-License-Identifier: MIT`, while retaining the root license.
- Simplify the generated/legacy `.gitignore`; remove duplicated section labels,
  old Xcode artifacts if no longer relevant, and the policy that ignores all
  `.xcodeproj` files unless project generation is actually part of the workflow.

### 16. Fix documentation and site issues

The README contains many spelling/grammar errors (`programming languge`,
`fullfilled`, `instace`, `consturctor`, `achived`, `thart`, `overwise`) and some
awkward or misleading wording. Rewrite it around a short motivation, installation,
core examples, failure semantics, concurrency guarantees, and composition.

Also:

- `_config.yml` specifies `jekyll-theme-caymanaa1dfd6`, which appears to be a
  corrupted theme name; use `jekyll-theme-cayman` or remove the obsolete Jekyll
  configuration in favor of DocC/GitHub Pages;
- update the Swift badge and installation text only when the baseline changes;
- ensure examples compile in CI;
- clarify that Swift throws errors, not exceptions;
- avoid promising GUI-ready human-facing errors until `LocalizedError` and
  localization/redaction are designed.

### 17. Reconsider aliases

`Require` and `Condition` are exact aliases of `Requirement`; they add vocabulary
without behavior and make search/documentation less predictable. For the major
release, prefer one canonical type. Deprecate aliases if real clients do not
demonstrate a readability benefit. If `Condition` is retained, give it distinct
semantics rather than another spelling.

## Swift 6 feature fit

Use features because they strengthen this library's contract, not simply because
they are new:

| Feature | Recommendation | Reason |
| --- | --- | --- |
| Swift 6 language mode / strict concurrency | Adopt now | Finds real closure-transfer and `Any` error-payload issues. |
| `Sendable` and `@Sendable` | Adopt after source-impact review | Makes immutable requirements safe to share across tasks. |
| Typed throws | Prototype | Excellent error precision, but risks an awkward extra generic parameter. |
| Result builders | Consider after batch semantics | Can make suites declarative without a macro dependency. |
| `callAsFunction` | Adopt | Small, stable, and concise. |
| Parameter packs / pack iteration | Skip for now | There is no heterogeneous variadic API in the current design that needs them. |
| Noncopyable types, `Span`, `InlineArray`, strict memory safety | Skip | The library has no ownership or low-level memory problem. |
| Swift 6.2 default actor isolation / `@concurrent` | Do not use in core | Synchronous validation should not be tied to an executor or global actor. |
| Swift 6.3 `@c`, module selectors, optimization attributes | Skip | No C boundary/name collision exists, and optimization annotations need benchmark evidence. |
| Macros | Defer | Build/dependency cost is disproportionate; builders and factories cover the likely DSL. |

## Suggested implementation order

1. Write short API decision records for predicate failures, input retention, and
   fail-fast versus accumulated validation.
2. Add a Swift 6 CI lane and resolve strict-concurrency diagnostics.
3. Introduce `SourceLocation` and the new error model.
4. Apply major-release renames/removals with migration shims where possible.
5. Add `callAsFunction`, named combinators, and batch validation.
6. Expand tests, DocC, CI platforms, and API compatibility checks.
7. Clean layout, formatting, README, aliases, Jekyll configuration, and release
   metadata.
8. Tag a prerelease and compile at least one external fixture against it before
   publishing the stable major version.
