/*
 
 MIT License
 
 Copyright (c) 2016 Maxim Khatskevich (maxim@khatskevi.ch)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

// MARK: - One-off validation

public
extension Requirement where T == Never, E == Never {
    /// Requires a lazily evaluated optional value to contain a value and returns it.
    ///
    /// The expression is evaluated exactly once. When it produces `nil`, the error
    /// uses an automatically generated description containing `Value`'s type.
    ///
    /// - Parameters:
    ///   - file: The source file recorded in an error. Defaults to the caller.
    ///   - line: The source line recorded in an error. Defaults to the caller.
    ///   - function: The function recorded in an error. Defaults to the caller.
    ///   - input: A lazily evaluated optional expression to unwrap.
    /// - Returns: The value wrapped by `input`.
    /// - Throws: ``RequirementError/unsatisfied(description:input:context:)``
    ///   when `input` evaluates to `nil`.
    @discardableResult
    static
    func nonNil<Value: Sendable>(
        file: String = #fileID,
        line: Int = #line,
        function: String = #function,
        _ input: @autoclosure () -> Value?
    ) throws(RequirementError<Value?, Never>) -> Value {
        try evaluateNonNil(
            description: nil,
            file: file,
            line: line,
            function: function,
            input
        )
    }

    /// Requires a lazily evaluated optional value to contain a value and returns it.
    ///
    /// The expression is evaluated exactly once. The supplied description is
    /// included in any error so callers can identify the failed requirement.
    ///
    /// - Parameters:
    ///   - file: The source file recorded in an error. Defaults to the caller.
    ///   - line: The source line recorded in an error. Defaults to the caller.
    ///   - function: The function recorded in an error. Defaults to the caller.
    ///   - description: A human-readable explanation of why the value is required.
    ///   - input: A lazily evaluated optional expression to unwrap.
    /// - Returns: The value wrapped by `input`.
    /// - Throws: ``RequirementError/unsatisfied(description:input:context:)``
    ///   when `input` evaluates to `nil`.
    @discardableResult
    static
    func nonNil<Value: Sendable>(
        file: String = #fileID,
        line: Int = #line,
        function: String = #function,
        _ description: String,
        _ input: @autoclosure () -> Value?
    ) throws(RequirementError<Value?, Never>) -> Value {
        try evaluateNonNil(
            description: description,
            file: file,
            line: line,
            function: function,
            input
        )
    }

    /// Requires an optional value produced by a throwing closure and returns it.
    ///
    /// The closure is evaluated exactly once. If no description is supplied, an
    /// explanation containing `Value`'s type is generated automatically.
    ///
    /// - Parameters:
    ///   - file: The source file recorded in an error. Defaults to the caller.
    ///   - line: The source line recorded in an error. Defaults to the caller.
    ///   - function: The function recorded in an error. Defaults to the caller.
    ///   - description: An optional human-readable explanation of why the value
    ///     is required.
    ///   - input: A closure that produces the optional value to unwrap and may
    ///     throw if it cannot be produced.
    /// - Returns: The value wrapped by the optional returned from `input`.
    /// - Throws: ``RequirementError/evaluationFailed(description:error:context:)``
    ///   when `input` throws, or
    ///   ``RequirementError/unsatisfied(description:input:context:)`` when it
    ///   returns `nil`.
    @discardableResult
    static
    func nonNil<Value: Sendable, EvaluationError: Error>(
        file: String = #fileID,
        line: Int = #line,
        function: String = #function,
        _ description: String? = nil,
        _ input: () throws(EvaluationError) -> Value?
    ) throws(RequirementError<Value?, EvaluationError>) -> Value {
        try evaluateNonNil(
            description: description,
            file: file,
            line: line,
            function: function,
            input
        )
    }

    /// Requires a lazily evaluated Boolean expression to be `true`.
    ///
    /// The expression is evaluated exactly once. Successful evaluation has no
    /// return value; failure retains the `false` input and source context.
    ///
    /// - Parameters:
    ///   - file: The source file recorded in an error. Defaults to the caller.
    ///   - line: The source line recorded in an error. Defaults to the caller.
    ///   - function: The function recorded in an error. Defaults to the caller.
    ///   - description: A human-readable explanation of the required condition.
    ///   - input: A lazily evaluated Boolean expression that must be `true`.
    /// - Throws: ``RequirementError/unsatisfied(description:input:context:)``
    ///   when `input` evaluates to `false`.
    static
    func that(
        file: String = #fileID,
        line: Int = #line,
        function: String = #function,
        _ description: String,
        _ input: @autoclosure () -> Bool
    ) throws(RequirementError<Bool, Never>) {
        try evaluateThat(
            description: description,
            file: file,
            line: line,
            function: function,
            input
        )
    }

    /// Requires a Boolean value produced by a throwing closure to be `true`.
    ///
    /// The closure is evaluated exactly once. Successful evaluation has no
    /// return value; failures retain either the thrown error or the `false`
    /// result together with source context.
    ///
    /// - Parameters:
    ///   - file: The source file recorded in an error. Defaults to the caller.
    ///   - line: The source line recorded in an error. Defaults to the caller.
    ///   - function: The function recorded in an error. Defaults to the caller.
    ///   - description: A human-readable explanation of the required condition.
    ///   - input: A closure that produces the Boolean value and may throw if it
    ///     cannot be produced.
    /// - Throws: ``RequirementError/evaluationFailed(description:error:context:)``
    ///   when `input` throws, or
    ///   ``RequirementError/unsatisfied(description:input:context:)`` when it
    ///   returns `false`.
    static
    func that<EvaluationError: Error>(
        file: String = #fileID,
        line: Int = #line,
        function: String = #function,
        _ description: String,
        _ input: () throws(EvaluationError) -> Bool
    ) throws(RequirementError<Bool, EvaluationError>) {
        try evaluateThat(
            description: description,
            file: file,
            line: line,
            function: function,
            input
        )
    }
}

private
extension Requirement where T == Never, E == Never {
    /// Evaluates the shared implementation of the optional-value requirements.
    ///
    /// - Parameters:
    ///   - description: The explanation stored in an error, or `nil` to generate
    ///     one from `Value`'s type.
    ///   - file: The source file stored in an error.
    ///   - line: The source line stored in an error.
    ///   - function: The function stored in an error.
    ///   - input: A closure that produces the optional value and may throw.
    /// - Returns: The value wrapped by the optional returned from `input`.
    /// - Throws: ``RequirementError/evaluationFailed(description:error:context:)``
    ///   when `input` throws, or
    ///   ``RequirementError/unsatisfied(description:input:context:)`` when it
    ///   returns `nil`.
    static
    func evaluateNonNil<Value: Sendable, EvaluationError: Error>(
        description: String?,
        file: String,
        line: Int,
        function: String,
        _ input: () throws(EvaluationError) -> Value?
    ) throws(RequirementError<Value?, EvaluationError>) -> Value {
        let resolvedDescription = description
            ?? "Non-nil instance of type \(String(reflecting: Value.self))"
        let result: Value?

        do {
            result = try input()
        } catch {
            throw RequirementError.evaluationFailed(
                description: resolvedDescription,
                error: error,
                context: RequirementContext(file: file, line: line, function: function)
            )
        }

        guard let result else {
            throw RequirementError.unsatisfied(
                description: resolvedDescription,
                input: nil,
                context: RequirementContext(file: file, line: line, function: function)
            )
        }

        return result
    }

    /// Evaluates the shared implementation of the Boolean requirements.
    ///
    /// - Parameters:
    ///   - description: The explanation stored in an error.
    ///   - file: The source file stored in an error.
    ///   - line: The source line stored in an error.
    ///   - function: The function stored in an error.
    ///   - input: A closure that produces the Boolean result and may throw.
    /// - Throws: ``RequirementError/evaluationFailed(description:error:context:)``
    ///   when `input` throws, or
    ///   ``RequirementError/unsatisfied(description:input:context:)`` when it
    ///   returns `false`.
    static
    func evaluateThat<EvaluationError: Error>(
        description: String,
        file: String,
        line: Int,
        function: String,
        _ input: () throws(EvaluationError) -> Bool
    ) throws(RequirementError<Bool, EvaluationError>) {
        let result: Bool

        do {
            result = try input()
        } catch {
            throw RequirementError.evaluationFailed(
                description: description,
                error: error,
                context: RequirementContext(file: file, line: line, function: function)
            )
        }

        guard result else {
            throw RequirementError.unsatisfied(
                description: description,
                input: result,
                context: RequirementContext(file: file, line: line, function: function)
            )
        }
    }
}
