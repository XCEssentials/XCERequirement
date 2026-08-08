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

public
enum Check {
    @discardableResult
    public
    static
    func nonEmpty<T>(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ description: String? = nil,
        _ inputBody: () throws -> T?
    ) throws -> T {

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

    @discardableResult
    public
    static
    func nonEmpty<T: Collection>(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ description: String? = nil,
        _ inputBody: () throws -> T?
    ) throws -> T {

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

    public
    static
    func that(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ description: String,
        _ input: Bool
    ) throws {

        try Check.that(
            file: file,
            line: line,
            function: function,
            description,
            { input }
        )
    }

    public
    static
    func that(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ description: String,
        _ inputBody: () throws -> Bool
    ) throws {

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
    func nonNil<T>(
        file: String,
        line: Int,
        function: String,
        description: String,
        _ inputBody: () throws -> T?
    ) throws -> T {

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
