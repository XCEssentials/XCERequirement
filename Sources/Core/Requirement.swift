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
struct UnsatisfiedRequirement: Swift.Error
{
    public
    let description: String
    
    public
    let input: Any
    
    public
    let context: (
        file: String,
        line: Int,
        function: String
        )
}

//---

public
struct Requirement<Input>: CustomStringConvertible
{
    public
    typealias Body = (Input) throws -> Bool

    //---

    public
    let description: String

    private
    let body: Body

    // MARK: - Initializers

    public
    init(
        _ description: String,
        _ body: @escaping Body
        )
    {
        self.description = description
        self.body = body
    }
}

// MARK: - Validation

public
extension Requirement
{
    func isValid(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ value: Input
        ) throws -> Bool
    {
        do
        {
            try validate(
                file: file,
                line: line,
                function: function,
                value
            )
            return true
        }
        catch is UnsatisfiedRequirement
        {
            return false
        }
    }
    
    func validate(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ value: Input
        ) throws
    {
        guard
            try body(value)
        else
        {
            throw UnsatisfiedRequirement(
                description: description,
                input: value,
                context: (
                    file,
                    line,
                    function
                )
            )
        }
    }
}
