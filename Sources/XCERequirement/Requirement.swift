// SPDX-License-Identifier: MIT
// Copyright (c) 2016 Maxim Khatskevich

/// A named, reusable predicate that validates `Sendable` values of `T`.
///
/// A requirement keeps its human-readable ``description`` together with the
/// code that evaluates it. A throwing predicate is reported as a structured
/// ``RequirementError`` by ``validate(file:line:function:_:)``.
///
/// - Parameters:
///   - T: The `Sendable` input value type accepted by the predicate.
///   - E: The concrete error type the predicate may throw.
public struct Requirement<T: Sendable, E: Error>: CustomStringConvertible, Sendable {
    /// The predicate used to evaluate an input value.
    ///
    /// A body receives one value of `T`, returns `true` when that value satisfies
    /// the requirement, and may throw `E` when evaluation cannot be completed.
    public typealias Body = @Sendable (T) throws(E) -> Bool

    /// A human-readable explanation of the condition an input must satisfy.
    public let description: String

    private let body: Body

    // MARK: - Initializers

    /// Creates a requirement from a description and predicate.
    ///
    /// - Parameters:
    ///   - description: A human-readable explanation of the requirement.
    ///   - body: A predicate that returns `true` when its input satisfies the
    ///     requirement. It may throw if evaluation cannot be completed.
    ///
    /// The predicate is stored for later calls to
    /// ``validate(file:line:function:_:)`` or, when nonthrowing,
    /// ``isSatisfied(by:)``. This initializer does not evaluate it.
    public init(
        _ description: String,
        _ body: @escaping Body
    ) {
        self.description = description
        self.body = body
    }
}

// MARK: - Validation

public extension Requirement {
    /// Validates a value using function-call syntax.
    ///
    /// - Parameter value: The value to evaluate.
    /// - Throws: ``RequirementError/unsatisfied(description:input:context:)``
    ///   when the predicate returns `false`, or
    ///   ``RequirementError/evaluationFailed(description:error:context:)`` when
    ///   the predicate throws.
    ///
    /// Errors use ``RequirementContext/unknown`` because function-call syntax
    /// does not provide a meaningful diagnostic call site in this API. Call
    /// ``validate(file:line:function:_:)`` when source context should be captured.
    func callAsFunction(
        _ value: T
    ) throws(RequirementError<T, E>) {
        try validate(context: .unknown, value)
    }

    /// Validates a value or throws a structured ``RequirementError``.
    ///
    /// - Parameters:
    ///   - file: The source file recorded in an error. Defaults to the caller.
    ///   - line: The source line recorded in an error. Defaults to the caller.
    ///   - function: The function recorded in an error. Defaults to the caller.
    ///   - value: The value to evaluate.
    /// - Throws: ``RequirementError/unsatisfied(description:input:context:)``
    ///   when the predicate returns `false`, or
    ///   ``RequirementError/evaluationFailed(description:error:context:)`` when
    ///   the predicate throws.
    ///
    /// The predicate is evaluated exactly once. A successful validation returns
    /// no value.
    func validate(
        file: String = #fileID,
        line: Int = #line,
        function: String = #function,
        _ value: T
    ) throws(RequirementError<T, E>) {
        try validate(
            context: RequirementContext(file: file, line: line, function: function),
            value
        )
    }
}

private extension Requirement {
    func validate(
        context: RequirementContext,
        _ value: T
    ) throws(RequirementError<T, E>) {
        let result: Bool

        do {
            result = try body(value)
        } catch {
            throw RequirementError.evaluationFailed(
                description: description,
                error: error,
                context: context
            )
        }

        guard result else {
            throw RequirementError.unsatisfied(
                description: description,
                input: value,
                context: context
            )
        }
    }
}

public extension Requirement where E == Never {
    /// Returns whether a value satisfies this nonthrowing requirement.
    ///
    /// - Parameter value: The value to evaluate.
    /// - Returns: The Boolean result of the predicate.
    func isSatisfied(by value: T) -> Bool {
        body(value)
    }
}
