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

/// A named, reusable predicate that validates values of `Input`.
///
/// A requirement keeps its human-readable ``description`` together with the
/// code that evaluates it. A throwing predicate is reported as a structured
/// ``RequirementError`` by ``validate(file:line:function:_:)``.
public
struct Requirement<Input>: CustomStringConvertible {
    /// The closure used to evaluate an input value.
    public
    typealias Body = (Input) throws -> Bool

    // ---

    /// A human-readable explanation of the condition an input must satisfy.
    public
    let description: String

    private
    let body: Body

    // MARK: - Initializers

    /// Creates a requirement from a description and predicate.
    ///
    /// - Parameters:
    ///   - description: A human-readable explanation of the requirement.
    ///   - body: A predicate that returns `true` when its input satisfies the
    ///     requirement. It may throw if evaluation cannot be completed.
    public
    init(
        _ description: String,
        _ body: @escaping Body
    ) {
        self.description = description
        self.body = body
    }
}

// MARK: - Validation

public
extension Requirement {
    /// Returns whether a value satisfies this requirement.
    ///
    /// This returns `false` both when the predicate returns `false` and when it
    /// throws. Use ``validate(file:line:function:_:)`` when that distinction is
    /// needed.
    ///
    /// - Parameters:
    ///   - file: The source file recorded on failure. Defaults to the caller.
    ///   - line: The source line recorded on failure. Defaults to the caller.
    ///   - function: The function recorded on failure. Defaults to the caller.
    ///   - value: The value to evaluate.
    /// - Returns: `true` only when the predicate completes and returns `true`.
    func isValid(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ value: Input
    ) -> Bool {
        do {
            try validate(
                file: file,
                line: line,
                function: function,
                value
            )
            return true
        } catch {
            return false
        }
    }

    /// Validates a value or throws a structured ``RequirementError``.
    ///
    /// - Parameters:
    ///   - file: The source file recorded in an error. Defaults to the caller.
    ///   - line: The source line recorded in an error. Defaults to the caller.
    ///   - function: The function recorded in an error. Defaults to the caller.
    ///   - value: The value to evaluate.
    /// - Throws: ``RequirementError/unsatisfied(description:input:context:)``
    ///   when the predicate returns `false`, or `RequirementError.evaluationFailed`
    ///   when the predicate throws.
    func validate(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ value: Input
    ) throws {
        let result: Bool

        // ---

        do {
            result = try body(value)
        } catch {
            throw RequirementError.evaluationFailed(
                description: description,
                error: error,
                context: RequirementContext(file: file, line: line, function: function)
            )
        }

        // ---

        guard
            result
        else {
            throw RequirementError.unsatisfied(
                description: description,
                input: value,
                context: RequirementContext(file: file, line: line, function: function)
            )
        }
    }
}
