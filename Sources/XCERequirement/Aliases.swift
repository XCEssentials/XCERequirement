// SPDX-License-Identifier: MIT
// Copyright (c) 2016 Maxim Khatskevich

/// A concise spelling of ``Requirement`` for requirement declarations.
///
/// - Parameters:
///   - T: The `Sendable` input value type.
///   - E: The error type the requirement's predicate may throw.
public typealias Require<T: Sendable, E: Error> = Requirement<T, E>

/// An alternative spelling of ``Requirement`` for condition-oriented APIs.
///
/// - Parameters:
///   - T: The `Sendable` input value type.
///   - E: The error type the condition's predicate may throw.
public typealias Condition<T: Sendable, E: Error> = Requirement<T, E>

/// An alternative spelling of ``Requirement`` for check-oriented APIs.
///
/// - Parameters:
///   - T: The `Sendable` input value type.
///   - E: The error type the check's predicate may throw.
public typealias Check<T: Sendable, E: Error> = Requirement<T, E>
