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

/// The source location from which a requirement was evaluated.
///
/// Validation APIs populate this value from `#file`, `#line`, and `#function`
/// by default. Pass explicit values when validation is forwarded through a
/// wrapper and the wrapper's caller should be reported instead.
public struct RequirementContext {
    /// The source file in which validation was requested.
    public let file: String
    /// The source line on which validation was requested.
    public let line: Int
    /// The function from which validation was requested.
    public let function: String

    /// Creates source context for a requirement evaluation.
    ///
    /// - Parameters:
    ///   - file: The source file in which validation was requested.
    ///   - line: The source line on which validation was requested.
    ///   - function: The function from which validation was requested.
    public init(file: String, line: Int, function: String) {
        self.file = file
        self.line = line
        self.function = function
    }
}
