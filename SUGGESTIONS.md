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
- add ordinary composition and batch-validation APIs before a result builder;
- keep macros and property wrappers outside the core unless concrete client
  use cases justify their semantics and maintenance cost.

## P0 — settle before release

## P1 — tests, CI, and package policy

### 14. Expand the test strategy

- Adopt Swift Testing, or run it alongside XCTest, for parameterized truth
  tables and clearer `#expect`/`#require` diagnostics.
- Test exact source propagation for every public entry point, nested errors,
  default descriptions, composition truth tables, short-circuiting, batch
  ordering, and sendability compile checks.
- Group tests by public type.
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
