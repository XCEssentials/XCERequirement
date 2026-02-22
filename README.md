[![GitHub License](https://img.shields.io/github/license/XCEssentials/Requirement.svg?longCache=true)](LICENSE)
[![GitHub Tag](https://img.shields.io/github/tag/XCEssentials/Requirement.svg?longCache=true)](https://github.com/XCEssentials/Requirement/tags)
[![Swift Package Manager Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?longCache=true)](Package.swift)
[![Written in Swift](https://img.shields.io/badge/Swift-5.10%2B-orange.svg?longCache=true)](https://swift.org)
[![Supported platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-blue.svg?longCache=true)](Package.swift)
[![CI](https://github.com/XCEssentials/Requirement/actions/workflows/ci.yml/badge.svg)](https://github.com/XCEssentials/Requirement/actions/workflows/ci.yml)

# Requirement

Describe requirements in a declarative, easy-readable format.

## Problem

When it comes to definition of how an app should work, there are many [requirements](https://en.wikipedia.org/wiki/Requirement) that should be implemented in source code. Every requirement, obviously, can be described in a human-friendly language, as well as formalized in a programming languge (computer-friendly).

## Pre-existing solutions

Usually requirements are being implemented in a batch as part of a task/model/etc. without an obvious direct translation of specific requirement into exact line/range of code in the app.

In most cases, every single requirement from specification (task definition) is being translated into some code in data model or business logic and that's it. That means there is not much semantics provided by such implementation - if this requirement is not fullfilled, it's not clear how to report the issue formally to the outer scope and/or in human-friendly format to the user (via GUI). If such reporting is implemented - it usually leads to spreading of the requirement implementation into few different parts: actual requirement check, error description for reporting to outer scope (or API user), and human-friendly representation for reporting via GUI to user.

Such implementation of requirements is hard to test/validate, keep consistent over time (when minor changes happen in a given requirement) and makes source code hard to understand and reason about.

## Wishlist

Ideally there should be a tool that allows:

1. bind requirement human-friendly description (variable length text) and its computer-friendly formal representation (piece of code) together in a single statement;
2. keep focus on content, make the wrapping expressions as minimal as possible;
3. automate requirement validation and success/failure reporting to both outer scope and GUI.

## Approach overview

Each requirement can be evaluated against a given data value (which can be an atomic or complex data type). In the other words, every requirement definition can be represented in form of a function that takes one or several input parameters and returns `Boolean` value - `true` means that requirement is fullfilled with provided input values, and `false` means the opposite.

## How to install

Install using [SwiftPM](https://swift.org/package-manager/). The package currently targets Swift tools version `5.10` and newer.

## How it works

It's a small and very simple, yet powerful library.

`Requirement` is the main data type that actually represents a single requirement. Note, that this is a `struct`, so once it's created, it works as a single atomic value.

To define a requirement, create an instace of `Requirement`. Its consturctor accepts two necessary parameters - human friendly description in form of a `String` and a closure that implements formal representation. Moreover, `Requirement` is a generic type, `Input` generic type represents the type of expected input parameters for the closure.

## How to use

Here is an example of how to create a requirements, that an integer number should not be equal to zero.

```swift
let r = Requirement<Int>("Non-zero") { $0 != 0 }
```

Same can be achived by using a helper typealias `Require`:

```swift
let r = Require<Int>("Non-zero") { $0 != 0 }
```

In the example above we created an instace of `Requirement` that supposed to evaluate values of type `Int`. We pass a string as the only parameter of constructor function, while second parameter (the closure) is being passed as trailing closure. The closure contains the code thart will be called each time this requirement needs to be evaluated, with corresponding value that needs to be checked as the only input parameter.

Note, that If a requirement contains phrases like **AND**, **OR** or any other logical [operators](https://en.wikipedia.org/wiki/Operator_(mathematics)), then such requirement *should* be divided into independent requirements.

When requirement is created, here is an example of how it might be used for checking potentially suitable values.

```swift
do
{
    if
        try r.isValid(14) // returns Bool, rethrows check-evaluation errors
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
}
catch
{
    print(error)
}
```

Same check can be done by utilizing Swift [error handling](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/ErrorHandling.html), see example below.

```swift
do
{
    try r.validate(0) // this will throw exception
}
catch
{
    print(error) // error is of 'UnsatisfiedRequirement' type
}
```

The `UnsatisfiedRequirement` data type has three parameters:

- `let description: String` that contains description of the requirement;
- `let input: Any` that contains exact input data value that has been evaluated and failed to fulfill the requirement.
- `let context: (file: String, line: Int, function: String)` for source context.

## Inline helpers

While `Requirement` itself might be more useful to implement **[data model](https://en.wikipedia.org/wiki/Data_model)**, there are several helpers that use the same idea but provide API that is more convenient for inline use when implementing **[business logic](https://en.wikipedia.org/wiki/Business_logic)**. These helpers are encapsulated into the `Check` enum. They throw a `FailedCheck` error when the check is not fulfilled.

When you have an `Optional` value or you have a function/closure that produces `Optional` value, and you need this value only if it's NOT `nil`, or throw an error otherwise:

```swift
// the following expression will throw
// if the value from closure is 'nil' or just return
// unwrapped value of the optional from closure overwise
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

When you have a `Bool` value or you have a function/closure that produces `Bool` value, and you want to continue only if it's `true`, or throw an error otherwise:

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

`FailedCheck` has these cases:

- `errorDuringConditionCheck(description:error:context:)`
- `unsatisfiedNonEmptyCondition(description:context:)`
- `unsatisfiedCondition(description:context:)`
