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

        do
        {
            try Requirement("Non-zero value"){ $0 != value }.validate(value)
        }
        catch
        {
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
        
        do
        {
            try Check.that("Non-zero value") {
                
                try Container.failingProperty
            }
            
        }
        catch
        {
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

        do
        {
            try Check.that("Non-zero value", value != 0 )
        }
        catch
        {
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
}
