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

/// Namespace for one-off validations that throw structured ``RequirementError``
/// values.
public
enum Check {
    /// Evaluates and unwraps an optional value.
    ///
    /// Unlike the collection overload, this only requires a non-`nil` value.
    ///
    /// - Parameters:
    ///   - file: The source file recorded in an error. Defaults to the caller.
    ///   - line: The source line recorded in an error. Defaults to the caller.
    ///   - function: The function recorded in an error. Defaults to the caller.
    ///   - description: A human-readable description. A type-based description
    ///     is generated when this is omitted.
    ///   - inputBody: A closure that produces the optional value.
    /// - Returns: The unwrapped value.
    /// - Throws: ``RequirementError/unsatisfied(description:input:context:)``
    ///   if the value is `nil`, or
    ///   ``RequirementError/evaluationFailed(description:error:context:)`` if
    ///   `inputBody` throws.
    @discardableResult
    public
    static
    func nonEmpty<T: Sendable, E: Error>(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ description: String? = nil,
        _ inputBody: () throws(E) -> T?
    ) throws(RequirementError<T?, E>) -> T {

        let description = description ?? "Non-nil instance of type \(String(reflecting: T.self))"

        // ---

        return try nonNil(
            file: file,
            line: line,
            function: function,
            description: description,
            inputBody
        )
    }

    /// Evaluates and unwraps an optional collection, requiring it to be non-empty.
    ///
    /// - Parameters:
    ///   - file: The source file recorded in an error. Defaults to the caller.
    ///   - line: The source line recorded in an error. Defaults to the caller.
    ///   - function: The function recorded in an error. Defaults to the caller.
    ///   - description: A human-readable description. A type-based description
    ///     is generated when this is omitted.
    ///   - inputBody: A closure that produces the optional collection.
    /// - Returns: The unwrapped, non-empty collection.
    /// - Throws: ``RequirementError/unsatisfied(description:input:context:)``
    ///   if the collection is `nil` or empty, or
    ///   ``RequirementError/evaluationFailed(description:error:context:)`` if
    ///   `inputBody` throws.
    @discardableResult
    public
    static
    func nonEmpty<T: Collection & Sendable, E: Error>(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ description: String? = nil,
        _ inputBody: () throws(E) -> T?
    ) throws(RequirementError<T?, E>) -> T {

        let description = description ?? "Non-empty instance of type \(String(reflecting: T.self))"

        // ---

        let result: T = try nonNil(
            file: file,
            line: line,
            function: function,
            description: description,
            inputBody
        )

        // ---

        guard
            !result.isEmpty
        else {
            throw RequirementError.unsatisfied(
                description: description,
                input: result,
                context: RequirementContext(file: file, line: line, function: function)
            )
        }

        // ---

        return result
    }

    /// Requires a Boolean value to be `true`.
    ///
    /// - Parameters:
    ///   - file: The source file recorded in an error. Defaults to the caller.
    ///   - line: The source line recorded in an error. Defaults to the caller.
    ///   - function: The function recorded in an error. Defaults to the caller.
    ///   - description: A human-readable explanation of the condition.
    ///   - input: The value to check.
    /// - Throws: ``RequirementError/unsatisfied(description:input:context:)``
    ///   when `input` is `false`. This overload cannot produce an evaluation
    ///   failure.
    public
    static
    func that(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ description: String,
        _ input: Bool
    ) throws(RequirementError<Bool, Never>) {

        try Check.that(
            file: file,
            line: line,
            function: function,
            description,
            { input }
        )
    }

    /// Evaluates a Boolean condition and requires its result to be `true`.
    ///
    /// - Parameters:
    ///   - file: The source file recorded in an error. Defaults to the caller.
    ///   - line: The source line recorded in an error. Defaults to the caller.
    ///   - function: The function recorded in an error. Defaults to the caller.
    ///   - description: A human-readable explanation of the condition.
    ///   - inputBody: A closure that evaluates the condition.
    /// - Throws: ``RequirementError/unsatisfied(description:input:context:)``
    ///   if the closure returns `false`, or
    ///   ``RequirementError/evaluationFailed(description:error:context:)`` if
    ///   it throws.
    public
    static
    func that<E: Error>(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ description: String,
        _ inputBody: () throws(E) -> Bool
    ) throws(RequirementError<Bool, E>) {

        let result: Bool

        // ---

        do {
            result = try inputBody()
        } catch {
            throw RequirementError.evaluationFailed(
                description: description,
                error: error,
                context: RequirementContext(file: file, line: line, function: function)
            )
        }

        // ---

        if
            !result {
            throw RequirementError.unsatisfied(
                description: description,
                input: result,
                context: RequirementContext(file: file, line: line, function: function)
            )
        }
    }
}

private
extension Check {
    static
    func nonNil<T: Sendable, E: Error>(
        file: String,
        line: Int,
        function: String,
        description: String,
        _ inputBody: () throws(E) -> T?
    ) throws(RequirementError<T?, E>) -> T {

        let resultMaybe: T?

        // ---

        do {
            resultMaybe = try inputBody()
        } catch {
            throw RequirementError.evaluationFailed(
                description: description,
                error: error,
                context: RequirementContext(file: file, line: line, function: function)
            )
        }

        // ---

        if
            let result = resultMaybe {
            return result
        } else {
            throw RequirementError.unsatisfied(
                description: description,
                input: nil,
                context: RequirementContext(file: file, line: line, function: function)
            )
        }
    }
}
