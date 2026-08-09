[![GitHub License](https://img.shields.io/github/license/XCEssentials/Requirement.svg?longCache=true)](LICENSE)
[![GitHub Tag](https://img.shields.io/github/tag/XCEssentials/Requirement.svg?longCache=true)](https://github.com/XCEssentials/Requirement/tags)
[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?longCache=true)](Package.swift)
[![Written in Swift](https://img.shields.io/badge/Swift-6.0%2B-orange.svg?longCache=true)](https://swift.org)
[![Supported platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Mac%20Catalyst%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS%20%7C%20Linux-blue.svg?longCache=true)](Package.swift)
[![CI](https://github.com/XCEssentials/Requirement/actions/workflows/ci.yml/badge.svg)](https://github.com/XCEssentials/Requirement/actions/workflows/ci.yml)

# Requirement

Describe requirements in a declarative, easy-to-read format.

## Problem

When it comes to defining how an app should work, there are many [requirements](https://en.wikipedia.org/wiki/Requirement) that should be implemented in source code. Every requirement can be described in human-friendly language as well as formalized in a programming language (computer-friendly).

## Pre-existing solutions

Usually requirements are being implemented in a batch as part of a task/model/etc. without an obvious direct translation of specific requirement into exact line/range of code in the app.

In most cases, every single requirement from a specification (task definition) is translated into some code in the data model or business logic, and that's it. That means there is not much semantics provided by such an implementation—if this requirement is not fulfilled, it's not clear how to report the issue formally to the outer scope and/or in a human-friendly format to the user (via GUI). If such reporting is implemented, it usually leads to spreading the requirement implementation across a few different parts: the actual requirement check, an error description for reporting to the outer scope (or API user), and a human-friendly representation for reporting via the GUI.

Such implementation of requirements is hard to test/validate, keep consistent over time (when minor changes happen in a given requirement) and makes source code hard to understand and reason about.

## Wishlist

Ideally there should be a tool that allows:

1. bind a requirement's human-friendly description (variable-length text) and its computer-friendly formal representation (piece of code) together in a single statement;
2. keep focus on content, make the wrapping expressions as minimal as possible;
3. automate requirement validation and success/failure reporting to both outer scope and GUI.

## Approach overview

Each requirement can be evaluated against a given data value (which can be an atomic or complex data type). In other words, every requirement definition can be represented as a function that takes one or several input parameters and returns a Boolean value—`true` means that the requirement is fulfilled by the provided input values, and `false` means the opposite.

## How to install

Install using [SwiftPM](https://swift.org/package-manager/). The package requires Swift tools version `6.0` or newer and compiles in Swift 6 language mode.

Add the package URL and a version requirement in Xcode, or add it to your
`Package.swift`, then include `XCERequirement` in your target dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/XCEssentials/Requirement.git", from: "4.0.0")
]
```

Import the module where it is used:

```swift
import XCERequirement
```

## How it works

It's a small and very simple, yet powerful library.

`Requirement<T, E>` is the main data type that represents a single requirement. It is generic over a `Sendable` input type `T` and the predicate's concrete `Error` type `E`.

To define a requirement, create an instance of `Requirement`. Its initializer accepts two required parameters: a human-friendly description in the form of a `String`, and a predicate that returns `true` for a valid value. The predicate may throw. Use `Never` as the error type for predicates that cannot throw.

## How to use

Here is an example of how to create a requirement that an integer must not equal zero.

```swift
let r = Requirement<Int, Never>("Non-zero") { $0 != 0 }
```

The same can be achieved by using the `Require` type alias:

```swift
let r = Require<Int, Never>("Non-zero") { $0 != 0 }
```

`Condition<T, E>` and `Check<T, E>` are aliases of `Requirement<T, E>` for
condition-oriented and check-oriented APIs, respectively.

In the example above, we created an instance of `Requirement` that evaluates values of type `Int`. We pass a string as the first initializer argument and the predicate as a trailing closure. The closure is called with each value that needs to be checked.

Note that if a requirement contains phrases like **AND**, **OR**, or any other logical [operators](https://en.wikipedia.org/wiki/Operator_(mathematics)), then that requirement *should* be divided into independent requirements.

When requirement is created, here is an example of how it might be used for checking potentially suitable values.

```swift
if r.isSatisfied(by: 14) {
    // 14 fulfills the requirement.
    print("\(r.description) -> YES")
} else {
    // The predicate returned false.
    print("\(r.description) -> NO")
}
```

The same check can be done using Swift [error handling](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/errorhandling/):

```swift
do
{
    try r.validate(0) // throws because the requirement is unsatisfied
}
catch
{
    print(error) // error is a RequirementError<Int, Never>
}
```

`validate` throws a `RequirementError<T, E>`. Its cases are:

- `unsatisfied(description: String, input: T, context: RequirementContext)` when the predicate returns `false`;
- `evaluationFailed(description: String, error: E, context: RequirementContext)` when the predicate throws.

The context contains the module-qualified source file ID, line, and function
and is populated from `#fileID`, `#line`, and `#function` at the call site by
default. Each validation API also accepts explicit `file`, `line`, and
`function` arguments for forwarding through wrappers.

For nonthrowing predicates, use `isSatisfied(by:)` when only a Boolean is
needed. Throwing predicates deliberately have no Boolean convenience because
it would hide evaluation errors; use `validate(_:)` and handle its typed
`RequirementError<T, E>` instead.

## Inline helpers

`Requirement` also provides static APIs that are convenient for one-off inline checks when implementing **[business logic](https://en.wikipedia.org/wiki/Business_logic)**. They throw a typed `RequirementError<T, E>` when a requirement is not fulfilled or cannot be evaluated.

`Requirement.nonNil` lazily evaluates an optional expression and returns its
unwrapped value. An empty collection is valid as long as it is non-`nil`. The
description is optional and defaults to a message based on the value's type:

```swift
let nonNilValue = try Requirement.nonNil("Value is not nil", optionalValue)
let values = try Requirement.nonNil(optionalArray)
```

The return value is marked `@discardableResult`, so the same API can be used
only for validation:

```swift
try Requirement.nonNil("Value is not nil", optionalValue)
```

`Requirement.that` accepts a lazy Boolean expression, while its closure
overload supports throwing evaluation:

```swift
try Requirement.that("Value is positive", value > 0)
try Requirement.that("Remote value is available") { try fetchAvailability() }
```

Closures supplied to `Requirement.that` and `Requirement.nonNil` preserve
their concrete thrown error type. Any thrown error is wrapped by
`evaluationFailed` and remains available in its `error` associated value.

`Requirement` is `Sendable`: its input type must conform to `Sendable`, and its
stored predicate is an `@Sendable` closure. Requirements can therefore be
transferred between concurrency domains, while the compiler rejects predicates
that capture unsafe non-`Sendable` state.
