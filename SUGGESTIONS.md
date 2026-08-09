# Suggestions for the next major release

Reviewed on 2026-08-09 against the current repository with Apple Swift 6.2.4.
All 15 XCTest tests pass. Swift 6.3 is the latest stable Swift release; Swift
6.4 has been announced but is not yet stable, so it should not be the release
baseline.

## Recommended direction

Keep the core library small and dependency-free. Use the next major release to
settle the failure model, concurrency contract, source diagnostics, and naming
before adding DSL syntax. The recommended baseline and sequence are:

- retain Swift tools 6.0 and Swift 6 language mode;
- support the oldest toolchain promised by the package and test it alongside
  the latest stable Swift release;
- make requirements genuinely safe to transfer between concurrency domains;
- replace repeated source parameters with a first-class source-location value;
- add ordinary composition and batch-validation APIs before a result builder;
- keep macros and property wrappers outside the core unless concrete client
  use cases justify their semantics and maintenance cost.

## P0 — settle before release

### 4. Make source location a first-class value

Every entry point currently repeats `file`, `line`, and `function`, even though
`RequirementContext` already groups those values after a failure occurs.
Replace those parameters with a value that supplies its own call-site defaults:

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

Then accept `source: SourceLocation = .init()` at public boundaries. Prefer
`#fileID` to the current `#file` so diagnostics do not expose absolute build
paths. If full paths are required, make `#filePath` an explicitly named opt-in.
Either rename `RequirementContext` to `SourceLocation` or evolve the existing
type; do not keep two overlapping public types.

### 5. Make errors useful diagnostics

The current generic enum preserves both the rejected input and concrete nested
error, which is a strong basis. Improve it by:

- adding `CustomStringConvertible` and `LocalizedError` where the resulting
  messages are stable and useful;
- defining whether nested failures are exposed as `underlyingError`;
- adding `Equatable`, `Hashable`, `Codable`, and `Sendable` only conditionally
  where their generic payloads support those conformances;
- deciding whether retaining the complete rejected input creates privacy,
  memory, or logging risks, and documenting redaction expectations;
- keeping the case vocabulary consistently `unsatisfied` and
  `evaluationFailed`.

Do not promise localization-ready GUI errors until localization and redaction
semantics are designed.

## P1 — API clarity and developer experience

### 6. Adopt names that read naturally

A possible surface is:

```swift
requirement.isSatisfied(by: value)
try requirement.validate(value)
try Check.require(value > 0, "Value must be positive")
let value = try Check.unwrap(optional, "Value must exist")
```

- Consider renaming `Check.that` to `require`.
- Separate `nonNil`/`unwrap` from a true collection `nonEmpty` operation. The
  current overload family uses “non-empty” for both non-`nil` optionals and
  non-empty collections.
- Consider `@autoclosure` for simple Boolean and optional expressions so they
  remain lazy without braces; retain explicit closure overloads for throwing
  evaluation.
- Put values, descriptions, and trailing closures in an order that behaves well
  in autocomplete and reads consistently across all overloads.

Use deprecated forwarding overloads and provide a migration table.

### 7. Add `callAsFunction`

This is a small convenience that fits the abstraction:

```swift
public func callAsFunction(
    _ value: T
) throws(RequirementError<T, E>) {
    try validate(value)
}

try isAdult(user)
```

Choose one callable meaning, preferably throwing validation. Do not create
Boolean and throwing forms that differ only by contextual return type.

### 8. Add principled composition

Splitting requirements and composing them are complementary. Start with named
combinators rather than operators:

```swift
let eligible = isAdult.and(hasConsent)
let recognized = isEmail.or(isPhoneNumber)
let permitted = isBlocked.negated()
```

Specify and test:

- short-circuiting;
- which evaluation error wins;
- composite description formatting;
- source-location propagation;
- whether composed requirements require identical `T` and `E` types.

Only consider `&&`, `||`, and prefix `!` after the named API proves clear.

### 9. Add batch validation before result-builder syntax

Create an ordinary `Requirements<T, E>` collection or equivalent API first:

```swift
let failures = requirements.failures(for: user)
try requirements.validateAll(user)
```

Settle fail-fast versus accumulated validation, ordering, evaluation-error
handling, and failure representation. Consider providing explicitly named
operations for both fail-fast and accumulation instead of one configurable
method.

After those semantics are stable, a result builder (sometimes called a content
builder) can be a useful thin syntax layer:

```swift
let accountRules = Requirements<Account, Never> {
    Requirement("Email is present") { !$0.email.isEmpty }

    if requiresConsent {
        Requirement("Consent is granted") { $0.hasConsent }
    }
}
```

The builder should only construct the collection; it should not define hidden
validation behavior.

### 10. Add focused factories for common predicates

Key-path and `Comparable` helpers could reduce repetition while remaining
strongly typed, for example:

```swift
Requirement.equals(\.status, .active, description: "Account is active")
Requirement.nonNil(\.owner, description: "Owner exists")
Requirement.contains(\.roles, .admin, description: "User is an admin")
```

Add only factories supported by repeated real client code. Avoid recreating a
large validation framework or duplicating standard-library algorithms.

## Features to defer or avoid

### 11. Keep macros optional and outside the core

The plausible macro is an expression macro such as:

```swift
#require(user.age >= 18)
```

It could capture expression spelling and source location automatically, but
source spelling is usually inferior to the human-facing description central to
this library. A macro also introduces compiler-plugin implementation and test
targets and increases build and maintenance cost.

Do not add a macro to the core product now. If real demand emerges, expose a
separate optional `XCERequirementMacros` product while keeping every operation
available through the normal API.

### 12. Do not use property wrappers in the core

An API such as `@Validated(by: .positive) var count` leaves essential behavior
unclear because property setters cannot naturally throw. Rejecting, trapping,
ignoring, or storing an invalid assignment would all be surprising in different
contexts, and initialization and mutation need different handling.

Only consider a wrapper in a separate integration layer after defining explicit
storage and failure semantics. Explicit validation is a better match for the
core abstraction.

### 13. Skip unrelated new language features

- Parameter packs have no current heterogeneous variadic use case.
- Noncopyable types, `Span`, `InlineArray`, and ownership modifiers solve no
  demonstrated problem in this closure-based library.
- Swift 6.3 `@c` and module selectors are irrelevant without a C boundary or
  module-name collision.
- Do not apply `@specialize`, `@inline(always)`, or implementation-visibility
  attributes without benchmark evidence; predicate execution will usually
  dominate validation overhead.
- Do not adopt default main-actor isolation or `@concurrent` in the synchronous
  core.

## P1 — tests, CI, and package policy

### 14. Expand the test strategy

- Adopt Swift Testing, or run it alongside XCTest, for parameterized truth
  tables and clearer `#expect`/`#require` diagnostics.
- Test exact source propagation for every public entry point, nested errors,
  default descriptions, composition truth tables, short-circuiting, batch
  ordering, and sendability compile checks.
- Rename `test_nonEmpty_successs` and group tests by public type.
- Add a small external fixture client; in-package tests do not expose every
  public-access and type-inference issue.
- Run `swift test --parallel`, a release build, and warning-as-error builds.
- Establish a sensible coverage target for this small package.

### 15. Correct and broaden CI

- Test minimum supported Swift 6.0 and latest stable Swift 6.3 on macOS and
  Linux.
- Consider Windows because the implementation uses only the standard library.
- Build each Apple platform claimed by project documentation.
- Pin third-party CI actions to commit SHAs.
- Add sanitizer coverage only if asynchronous or shared-state behavior is
  introduced.
- Do not claim Android, Windows, WebAssembly, or other platforms until CI builds
  and tests them.

### 16. Make platform policy consistent

The manifest currently declares macOS 12, while the README badge claims macOS,
iOS, tvOS, watchOS, and Linux. A macOS-only platform declaration does not mean
the package is restricted to macOS, but every claimed platform should have an
explicit support policy and CI evidence. Either declare appropriate Apple
minimum versions or state that support follows tested Swift toolchains. Avoid
deployment minimums that are not required by the standard-library-only code.

### 17. Add release-engineering safeguards

- Add `CHANGELOG.md` with a migration section.
- Add a DocC catalog and validate public documentation in CI.
- Use API-digester or symbol-graph comparison after the major release to catch
  accidental public API breaks.
- Add `CONTRIBUTING.md`, a supported-Swift policy, and a release checklist.
- Compile examples and at least one external fixture in CI.

## P2 — repository cleanup

### 18. Modernize layout and formatting

- Move sources to `Sources/XCERequirement/` and tests to
  `Tests/XCERequirementTests/`, then remove custom manifest paths.
- Split `AllTests.swift` into files grouped by subject.
- Adopt consistent standard Swift formatting; the current split modifiers and
  vertical whitespace make the small implementation harder to scan.
- Consider concise SPDX headers while retaining the root `LICENSE`.
- Review `.gitignore` for obsolete generated-project and legacy Xcode entries.

### 19. Keep documentation aligned with behavior

- Organize the README around installation, core examples, typed failure
  semantics, concurrency guarantees, composition, and batch validation.
- Keep the Swift badge and installation version aligned with the manifest.
- Ensure every example compiles in CI.
- Clarify that Swift throws errors, not exceptions.
- Retain the valid `jekyll-theme-cayman` configuration only if the Jekyll site
  remains in use; otherwise replace it with DocC-based publishing.

### 20. Reconsider aliases

`Require` and `Condition` are exact aliases of `Requirement`. They add
vocabulary without behavior and make API search less predictable. Prefer one
canonical type unless client usage demonstrates that an alias materially
improves readability. Deprecate removed aliases through forwarding typealiases;
if `Condition` remains, consider whether it should have distinct semantics.

## Swift feature decision table

| Feature | Decision | Reason |
| --- | --- | --- |
| Swift 6 language mode | Keep | Already enabled and enforces the intended language contract. |
| Typed throws | Keep and refine | Already provides precise predicate and validation failures. |
| `Sendable` / `@Sendable` | Adopted | Makes immutable requirements safe to transfer between tasks. |
| `#fileID` source values | Adopt | Improves privacy and shortens repeated APIs. |
| `callAsFunction` | Adopt | Small, idiomatic convenience with little maintenance cost. |
| Result builders | Add after batch semantics | Useful declarative syntax once the underlying model is explicit. |
| Macros | Defer to an optional product | Compiler-plugin cost is not justified by the current API. |
| Property wrappers | Avoid in core | Throwing validation does not map cleanly to property mutation. |
| Parameter packs | Skip | No heterogeneous variadic API requires them. |
| Ownership/noncopyable features | Skip | No low-level lifetime or memory problem exists here. |
| Swift 6.2 actor-isolation options | Avoid in core | Synchronous validation should remain executor-independent. |
| Swift 6.3 C/module/optimization features | Skip for now | No matching use case or benchmark evidence exists. |

## Suggested implementation order

1. Record decisions for input retention and fail-fast versus accumulated
   validation.
2. Add minimum/current Swift CI lanes and warning-as-error builds.
3. Introduce the source-location API and diagnostic error conformances.
4. Apply major-release renames with deprecated migration shims.
5. Add `callAsFunction` and named combinators.
6. Add batch validation, then consider a result builder.
7. Expand Swift Testing coverage, DocC, external fixtures, platform CI, and API
   compatibility checks.
8. Clean up layout, formatting, aliases, README, site configuration, and release
   metadata.
9. Publish a prerelease and compile real or representative clients against it
    before tagging the stable major version.
