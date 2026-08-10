// SPDX-License-Identifier: MIT
// Copyright (c) 2016 Maxim Khatskevich

import XCTest
import XCERequirement

final class InlineRequirementTests: XCTestCase {
    func test_inlineCheck_success() {
        let value = 14

        do {
            try Requirement.that("Non-zero value", value != 0)
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
            _ = try Requirement.that("Non-zero value", value != 0)
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
        let text: String? = "value"

        XCTAssertEqual(try Requirement.nonNil(text), "value")

        do {
            try Requirement.nonNil(value)

            let output: Int = try Requirement.nonNil(value)

            XCTAssertEqual(output, 1)
        } catch {
            XCTFail("Unexpected error")
        }

        do {
            try Requirement.nonNil("Value is set", value)

            let output: Int = try Requirement.nonNil("Value is set", value)

            XCTAssertEqual(output, 1)
        } catch {
            XCTFail("Unexpected error")
        }

        do {
            try Requirement.nonNil("Value is set", 2)

            let output: Int = try Requirement.nonNil("Value is set", 2)

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
            _ = try Requirement.nonNil("Custom check description", value)
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

}
