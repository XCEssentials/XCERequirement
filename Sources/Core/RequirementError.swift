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

/// An error produced while evaluating a ``Requirement`` API.
///
/// `T` is the checked input type and `E` is the concrete error type thrown by
/// the supplied predicate or input closure.
public enum RequirementError<T: Sendable, E: Error>: Error {
    /// The check completed normally, but its input did not satisfy the requirement.
    ///
    /// The associated `input` preserves the rejected value's concrete type.
    case unsatisfied(
        description: String,
        input: T,
        context: RequirementContext
    )

    /// The supplied closure threw before the requirement could be evaluated.
    ///
    /// The original error is preserved in the associated `error` value.
    case evaluationFailed(
        description: String,
        error: E,
        context: RequirementContext
    )
}
