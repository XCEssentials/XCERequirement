//
//  Main.swift
//  MKHRequirementTst
//
//  Created by Maxim Khatskevich on 12/19/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import XCTest

// @testable
import XCERequirement

// ===

class AllTests: XCTestCase {
    func test_requirement_isSendable() {
        func requireSendable<T: Sendable>(_: T) {}

        let body: Requirement<Int, Never>.Body = { $0 != 0 }
        let requirement = Requirement("Non-zero value", body)

        requireSendable(body)
        requireSendable(requirement)
    }

    func test_requirement_success() {
        do {
            try Requirement("Non-zero value") { $0 != 0 }.validate(14)
        } catch {
            XCTFail("Unexpected failure")
        }
    }

    func test_requirement_validate_wrapsConditionEvaluationError() {
        enum TestError: Error { case brokenCondition }

        let body = { @Sendable (_: Int) throws(TestError) -> Bool in
            throw TestError.brokenCondition
        }
        let requirement = Requirement("Any value", body)

        do {
            _ = try requirement.validate(14)
            XCTFail("Expected an error")
        } catch {
            guard
                case let RequirementError.evaluationFailed(desc, nestedError, context) = error
            else {
                return XCTFail("Unexpected error")
            }

            XCTAssertEqual(desc, "Any value")
            XCTAssertFalse(context.file.hasPrefix("/"))
            XCTAssertTrue(context.function.contains("test_requirement_validate_wrapsConditionEvaluationError"))
            guard case TestError.brokenCondition = nestedError else {
                return XCTFail("Unexpected nested error")
            }
        }
    }

    func test_requirement_unsatisfiedCondition() {
        let value = 0

        do {
            _ = try Requirement("Non-zero value") { $0 != value }.validate(value)
            XCTFail("Expected an error")
        } catch {
            guard
                case let RequirementError.unsatisfied(desc, input, context) = error
            else {
                return XCTFail("Unexpected validation error")
            }

            XCTAssertEqual(desc, "Non-zero value")
            XCTAssertEqual(input, value)
            XCTAssertTrue(context.function.contains("test_requirement_unsatisfiedCondition"))
        }
    }

    func test_requirement_unsatisfiedCondition_customContext() {
        let requirement = Requirement<Int, Never>("Non-zero value") { $0 != 0 }

        do {
            _ = try requirement.validate(
                file: "CustomFile.swift",
                line: 42,
                function: "customFunction()",
                0
            )
            XCTFail("Expected an error")
        } catch {
            guard
                case let RequirementError.unsatisfied(_, _, context) = error
            else {
                return XCTFail("Unexpected validation error")
            }

            XCTAssertEqual(context.file, "CustomFile.swift")
            XCTAssertEqual(context.line, 42)
            XCTAssertEqual(context.function, "customFunction()")
        }
    }

    func test_requirement_isSatisfied() {
        let requirement = Requirement<Int, Never>("Non-zero value") { $0 != 0 }

        XCTAssertTrue(requirement.isSatisfied(by: 1))
        XCTAssertFalse(requirement.isSatisfied(by: 0))
    }

    func test_inlineCheck_success() {
        let value = 14

        do {
            try Requirement.that(value != 0, "Non-zero value")
        } catch {
            XCTFail("Unexpected failure")
        }
    }

    func test_inlineCheck_errorDuringConditionCheck() {
        enum TestError: Error { case one }

        enum Container {
            static func failingValue() throws(TestError) -> Bool {
                throw TestError.one
            }
        }

        let condition = { () throws(TestError) -> Bool in
            try Container.failingValue()
        }

        do {
            _ = try Requirement.that("Non-zero value", condition)
            XCTFail("Expected an error")
        } catch {
            guard
                case let RequirementError.evaluationFailed(desc, nestedError, context) = error
            else {
                return XCTFail("Unexpected validation error")
            }

            XCTAssertEqual(desc, "Non-zero value")
            XCTAssertTrue(context.function.contains("test_inlineCheck_errorDuringConditionCheck"))

            guard
                case TestError.one = nestedError
            else {
                return XCTFail("Unexpected nested error")
            }
        }
    }

    func test_inlineCheck_unsatisfiedCondition() {
        let value = 0

        do {
            _ = try Requirement.that(value != 0, "Non-zero value")
            XCTFail("Expected an error")
        } catch {
            guard
                case let RequirementError.unsatisfied(desc, input, context) = error
            else {
                return XCTFail("Unexpected validation error")
            }

            XCTAssertEqual(desc, "Non-zero value")
            XCTAssertEqual(input, false)
            XCTAssertTrue(context.function.contains("test_inlineCheck_unsatisfiedCondition"))
        }
    }

    func test_nonNil_success() {
        let value: Int? = 1

        do {
            try Requirement.nonNil(value)

            let output: Int = try Requirement.nonNil(value)

            XCTAssertEqual(output, 1)
        } catch {
            XCTFail("Unexpected error")
        }

        do {
            try Requirement.nonNil(value, "Value is set")

            let output: Int = try Requirement.nonNil(value, "Value is set")

            XCTAssertEqual(output, 1)
        } catch {
            XCTFail("Unexpected error")
        }

        do {
            try Requirement.nonNil(2, "Value is set")

            let output: Int = try Requirement.nonNil(2, "Value is set")

            XCTAssertEqual(output, 2)
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func test_nonNil_failure() {
        let value: Int? = nil

        do {
            _ = try Requirement.nonNil(value)
            XCTFail("Expected an error")
        } catch {
            switch error {
            case RequirementError.unsatisfied(let desc, let input, _):
                XCTAssertEqual(desc, "Non-nil instance of type Swift.Int")
                XCTAssertNil(input)

            default:
                XCTFail("Unexpected error type")
            }
        }

        do {
            _ = try Requirement.nonNil(value, "Custom check description")
            XCTFail("Expected an error")
        } catch {
            switch error {
            case RequirementError.unsatisfied(let desc, let input, _):
                XCTAssertEqual(desc, "Custom check description")
                XCTAssertNil(input)

            default:
                XCTFail("Unexpected error type")
            }
        }
    }

    func test_nonNil_collectionDoesNotRequireNonEmpty() {
        let populated: [Int]? = [1]
        let empty: [Int]? = []

        XCTAssertEqual(try Requirement.nonNil(populated), [1])
        XCTAssertEqual(try Requirement.nonNil(empty), [])
    }

    func test_nonNil_errorDuringEvaluation_whenInputThrows() {
        enum TestError: Error { case brokenCondition }

        do {
            _ = try Requirement.nonNil("Value is set") { () throws(TestError) -> Int? in
                throw TestError.brokenCondition
            }
            XCTFail("Expected an error")
        } catch {
            guard
                case let RequirementError.evaluationFailed(desc, nestedError, context) = error
            else {
                return XCTFail("Unexpected validation error")
            }

            XCTAssertEqual(desc, "Value is set")
            XCTAssertTrue(context.function.contains("test_nonNil_errorDuringEvaluation_whenInputThrows"))
            guard
                case TestError.brokenCondition = nestedError
            else {
                return XCTFail("Unexpected nested error")
            }
        }
    }

    func test_nonNil_unsatisfiedCondition_customContext() {
        let value: Int? = nil

        do {
            _ = try Requirement.nonNil(
                file: "CustomFile.swift",
                line: 77,
                function: "customFunction()",
                "Value is set"
            ) { value }
            XCTFail("Expected an error")
        } catch {
            guard
                case let RequirementError.unsatisfied(desc, input, context) = error
            else {
                return XCTFail("Unexpected validation error")
            }

            XCTAssertEqual(desc, "Value is set")
            XCTAssertNil(input)
            XCTAssertEqual(context.file, "CustomFile.swift")
            XCTAssertEqual(context.line, 77)
            XCTAssertEqual(context.function, "customFunction()")
        }
    }

    func test_aliases_requireAndCondition() {
        let require: Require<Int, Never> = Require("Non-zero value") { $0 != 0 }
        let condition: Condition<Int, Never> = Condition("Positive value") { $0 > 0 }

        XCTAssertTrue(require.isSatisfied(by: 1))
        XCTAssertFalse(condition.isSatisfied(by: 0))
    }
}
