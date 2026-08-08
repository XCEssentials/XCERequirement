[![GitHub License](https://img.shields.io/github/license/XCEssentials/Requirement.svg?longCache=true)](LICENSE)
[![GitHub Tag](https://img.shields.io/github/tag/XCEssentials/Requirement.svg?longCache=true)](https://github.com/XCEssentials/Requirement/tags)
[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?longCache=true)](Package.swift)
[![Written in Swift](https://img.shields.io/badge/Swift-6.0%2B-orange.svg?longCache=true)](https://swift.org)
[![Supported platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-blue.svg?longCache=true)](Package.swift)
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
    .package(url: "https://github.com/XCEssentials/Requirement.git", from: "2.6.2")
]
```

Import the module where it is used:

```swift
import XCERequirement
```

## How it works

It's a small and very simple, yet powerful library.

`Requirement` is the main data type that actually represents a single requirement. Note, that this is a `struct`, so once it's created, it works as a single atomic value.

To define a requirement, create an instance of `Requirement`. Its initializer accepts two required parameters: a human-friendly description in the form of a `String`, and a closure that implements the formal representation. `Requirement` is generic over both the value expected by the closure and its concrete error type. Use `Never` for predicates that cannot throw.

## How to use

Here is an example of how to create a requirement that an integer must not equal zero.

```swift
let r = Requirement<Int, Never>("Non-zero") { $0 != 0 }
```

The same can be achieved by using the helper type alias `Require`:

```swift
let r = Require<Int, Never>("Non-zero") { $0 != 0 }
```

In the example above, we created an instance of `Requirement` that evaluates values of type `Int`. We pass a string as the first initializer argument and the predicate as a trailing closure. The closure is called with each value that needs to be checked.

Note that if a requirement contains phrases like **AND**, **OR**, or any other logical [operators](https://en.wikipedia.org/wiki/Operator_(mathematics)), then that requirement *should* be divided into independent requirements.

When requirement is created, here is an example of how it might be used for checking potentially suitable values.

```swift
if
    r.isValid(14) // returns Bool
{
	// given value - 14 (Int) - fulfills the requirement

	// r.description - the description that has been provided
	// during requirement initialization
	
    print("\(r.description) -> YES")
}
else
{
	// this code block will be executed,
    // if 0 will be passed into r.isValid(...)
	
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
    print(error) // error is a RequirementError<Never>
}
```

The `RequirementError.unsatisfied` case has three parameters:

- `let description: String` that contains description of the requirement;
- `let input: Any?` that contains the input data value that failed to fulfill the requirement, when available.
- `let context: RequirementContext` for source context.

The context is populated from the call site by default. If the predicate itself
throws, `validate` instead throws `RequirementError<E>.evaluationFailed`
and preserves the concrete error type. Use `isValid` only when this distinction is
unimportant, because it returns `false` for both an unsatisfied requirement and
an evaluation failure.

## Inline helpers

While `Requirement` itself might be more useful to implement **[data model](https://en.wikipedia.org/wiki/Data_model)**, there are several helpers that use the same idea but provide API that is more convenient for inline use when implementing **[business logic](https://en.wikipedia.org/wiki/Business_logic)**. These helpers are encapsulated into the `Check` enum. They throw a `RequirementError<E>` when a check is not fulfilled or cannot be evaluated.

When you have an `Optional` value or a function/closure that produces one, `Check.nonEmpty` returns its unwrapped value or throws when it is `nil`. If the value is a collection, it also throws when the collection is empty:

```swift
// the following expression will throw
// if the value from closure is 'nil' or just return
// the unwrapped value from the closure otherwise
let nonNilValue = try Check.nonEmpty("Value is NOT nil") {
	
	// return here an optional value,
	// it might be result of an expression 
	// or an optional value captured from the outer scope
}
```

Same as the above, but does not return anything. When you have an `Optional` value or you have a function/closure that produces `Optional` value, and you need to make sure that this value is NOT `nil`, or throw an error otherwise:

```swift
// the following expression does not return anything,
// it will throw if value IS 'nil'
// or pass through silently otherwise
try Check.nonEmpty("Value is NOT nil") {
	
	// return here an optional value,
	// it might be result of an expression 
	// or an optional value captured from the outer scope
}
```

When you have a `Bool` value or a function/closure that produces a `Bool`, and you want to continue only if it is `true`, or throw an error otherwise:

```swift
// the following expression does not return anything,
// it will throw if value is 'false'
// or pass through silently otherwise
try Check.that("Value is TRUE") {
	
	// return here a boolean value,
	// it might be result of an expression 
	// or an boolean value captured from the outer scope
}
```

`RequirementError` has these cases:

- `unsatisfied(description:input:context:)`
- `evaluationFailed(description:error:context:)`

Errors thrown by closures supplied to `Requirement`, `Check.that`, or
`Check.nonEmpty` are wrapped by `evaluationFailed`; the original error remains
available in its `error` associated value.
