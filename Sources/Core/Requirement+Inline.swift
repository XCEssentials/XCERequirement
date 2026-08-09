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
    /// Lazily evaluates and unwraps an optional value.
    @discardableResult
    static
    func nonNil<Value: Sendable>(
        file: String = #fileID,
        line: Int = #line,
        function: String = #function,
        _ input: @autoclosure () -> Value?,
        _ description: String? = nil
    ) throws(RequirementError<Value?, Never>) -> Value {
        try evaluateNonNil(
            description: description,
            file: file,
            line: line,
            function: function,
            input
        )
    }

    /// Evaluates and unwraps an optional value produced by a throwing closure.
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

    /// Lazily requires a Boolean expression to be `true`.
    static
    func that(
        file: String = #fileID,
        line: Int = #line,
        function: String = #function,
        _ input: @autoclosure () -> Bool,
        _ description: String
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
