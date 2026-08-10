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

import Foundation

/// An error produced while evaluating a ``Requirement`` API.
///
/// `T` is the checked input type and `E` is the concrete error type thrown by
/// the supplied predicate or input closure.
///
/// - Parameters:
///   - T: The `Sendable` input type retained by an unsatisfied error.
///   - E: The concrete underlying error type retained by an evaluation failure.
public enum RequirementError<T: Sendable, E: Error>: Error, CustomStringConvertible,
    LocalizedError {
    /// The check completed normally, but its input did not satisfy the requirement.
    ///
    /// The associated `input` preserves the rejected value's concrete type.
    ///
    /// - Parameters:
    ///   - description: The human-readable explanation of the requirement.
    ///   - input: The value that did not satisfy the requirement.
    ///   - context: The source location at which evaluation was requested.
    case unsatisfied(
        description: String,
        input: T,
        context: RequirementContext
    )

    /// The supplied closure threw before the requirement could be evaluated.
    ///
    /// The original error is preserved in the associated `error` value.
    ///
    /// - Parameters:
    ///   - description: The human-readable explanation of the requirement.
    ///   - error: The original error thrown while producing or checking a value.
    ///   - context: The source location at which evaluation was requested.
    case evaluationFailed(
        description: String,
        error: E,
        context: RequirementContext
    )

    /// A human-readable description of the failed requirement.
    public var description: String {
        switch self {
        case let .unsatisfied(description, input, _):
            "Unsatisfied requirement: \(description). Rejected input: \(input)"
        case let .evaluationFailed(description, error, _):
            "Requirement evaluation failed: \(description). Error: \(error)"
        }
    }

    /// A human-readable description suitable for standard error presentation.
    public var errorDescription: String? { description }
}

extension RequirementError: Equatable where T: Equatable, E: Equatable {}
extension RequirementError: Hashable where T: Hashable, E: Hashable {}
extension RequirementError: Codable where T: Codable, E: Codable {}
extension RequirementError: Sendable where E: Sendable {}
