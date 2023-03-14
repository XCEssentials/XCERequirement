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
enum FailedCheck: Swift.Error
{
    case errorDuringConditionCheck(
        description: String,
        error: Error,
        context: (
            file: String,
            line: Int,
            function: String
            )
    )
    
    case unsatisfiedCondition(
        description: String,
        context: (
            file: String,
            line: Int,
            function: String
            )
    )
}

//---

public
enum Check
{
    @discardableResult
    public
    static
    func nonEmpty<T>(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ input: T?,
        _ description: String? = nil
        ) throws -> T
    {
        if
            let result = input
        {
            return result
        }
        else
        {
            let defaultDescription: () -> String = {
                
                "Non-nil instance of type \(String(reflecting: T.self))"
            }
            
            throw FailedCheck.unsatisfiedCondition(
                description: description ?? defaultDescription(),
                context: (
                    file,
                    line,
                    function
                )
            )
        }
    }
    
    public
    static
    func that(
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        _ description: String,
        _ input: Bool
        ) throws
    {
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
        ) throws
    {
        let result: Bool
        
        //---
        do
        {
            result = try inputBody()
        }
        catch
        {
            throw FailedCheck.errorDuringConditionCheck(
                description: description,
                error: error,
                context: (
                    file,
                    line,
                    function
                )
            )
        }
        
        //---
        
        if
            !result
        {
            throw FailedCheck.unsatisfiedCondition(
                description: description,
                context: (
                    file,
                    line,
                    function
                )
            )
        }
    }
}
