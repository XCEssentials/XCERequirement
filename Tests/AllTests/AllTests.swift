//
//  Main.swift
//  MKHRequirementTst
//
//  Created by Maxim Khatskevich on 12/19/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import XCTest

//@testable
import XCERequirement

//===

class AllTests: XCTestCase
{
    func test_requirement_success()
    {
        do
        {
            try Requirement("Non-zero value"){ $0 != 0 }.validate(14)
        }
        catch
        {
            XCTFail("Unexpected failure")
        }
    }
    
    
    func test_requirement_unsatisfiedCondition()
    {
        let value = 0

        XCTAssertThrowsError(
            try Requirement("Non-zero value"){ $0 != value }.validate(value)
        )
        { error in
            guard
                let unsatisfiedRequirement = error as? UnsatisfiedRequirement
            else
            {
                return XCTFail("Unexpected validation error")
            }

            XCTAssertEqual(unsatisfiedRequirement.description, "Non-zero value")
            XCTAssert(unsatisfiedRequirement.input as! Int == value)
            XCTAssertTrue(unsatisfiedRequirement.context.function.contains("test_requirement_unsatisfiedCondition"))
        }
    }
    
    func test_inlineCheck_success()
    {
        let value = 14
        
        do
        {
            try Check.that("Non-zero value", value != 0)
        }
        catch
        {
            XCTFail("Unexpected failure")
        }
    }
    
    func test_inlineCheck_errorDuringConditionCheck()
    {
        enum Container
        {
            enum NestedError: Error { case one }
            
            static
            var failingProperty: Bool
            {
                get throws
                {
                    throw NestedError.one
                }
            }
        }
        
        XCTAssertThrowsError(
            try Check.that("Non-zero value") {
                
                try Container.failingProperty
            }
        )
        { error in
            guard
                case let FailedCheck.errorDuringConditionCheck(desc, nestedError, context) = error
            else
            {
                return XCTFail("Unexpected validation error")
            }
            
            XCTAssertEqual(desc, "Non-zero value")
            XCTAssertTrue(context.function.contains("test_inlineCheck_errorDuringConditionCheck"))
            
            guard
                case Container.NestedError.one = nestedError
            else
            {
                return XCTFail("Unexpected nested error")
            }
        }
    }
    
    func test_inlineCheck_unsatisfiedCondition()
    {
        let value = 0

        XCTAssertThrowsError(
            try Check.that("Non-zero value", value != 0 )
        )
        { error in
            guard
                case let FailedCheck.unsatisfiedCondition(desc, context) = error
            else
            {
                return XCTFail("Unexpected validation error")
            }

            XCTAssertEqual(desc, "Non-zero value")
            XCTAssertTrue(context.function.contains("test_inlineCheck_unsatisfiedCondition"))
        }
    }
    
    func test_nonEmpty_successs()
    {
        let value: Int? = 1
        
        do
        {
            try Check.nonEmpty { value }
            
            let output: Int = try Check.nonEmpty { value }
            
            XCTAssertEqual(output, 1)
        }
        catch
        {
            XCTFail("Unexpected error")
        }
        
        do
        {
            try Check.nonEmpty("Value is set") { value }
            
            let output: Int = try Check.nonEmpty("Value is set") { value }
            
            XCTAssertEqual(output, 1)
        }
        catch
        {
            XCTFail("Unexpected error")
        }
        
        do
        {
            try Check.nonEmpty("Value is set") { 2 }
            
            let output: Int = try Check.nonEmpty("Value is set") { 2 }
            
            XCTAssertEqual(output, 2)
        }
        catch
        {
            XCTFail("Unexpected error")
        }
    }
    
    func test_nonEmpty_failure()
    {
        let value: Int? = nil
        
        XCTAssertThrowsError(try Check.nonEmpty { value }) { error in
            switch error
            {
                case FailedCheck.unsatisfiedNonEmptyCondition(let desc, _):
                    XCTAssertEqual(desc, "Non-nil instance of type Swift.Int")
                    
                default:
                    XCTFail("Unexpected error type")
            }
        }
        
        XCTAssertThrowsError(
            try Check.nonEmpty("Custom check description") { value }
        )
        { error in
            switch error
            {
                case FailedCheck.unsatisfiedNonEmptyCondition(let desc, _):
                    XCTAssertEqual(desc, "Custom check description")
                    
                default:
                    XCTFail("Unexpected error type")
            }
        }
    }
}
