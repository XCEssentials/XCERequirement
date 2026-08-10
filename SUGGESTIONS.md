
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
