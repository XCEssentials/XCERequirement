// SPDX-License-Identifier: MIT
// Copyright (c) 2016 Maxim Khatskevich

import XCTest

import XCERequirement

final class RequirementTests: XCTestCase {
    private struct ComparableError: Error, Codable, Equatable, Hashable, Sendable {
        let message: String
    }

    func test_requirement_isSendable() {
        func requireSendable<T: Sendable>(_: T) {}

        let body: Requirement<Int, Never>.Body = { $0 != 0 }
        let requirement = Requirement("Non-zero value", body)

        requireSendable(body)
        requireSendable(requirement)
    }

    func test_requirementContext_unknown_hasNoSourceLocation() {
        XCTAssertEqual(RequirementContext.unknown.file, "")
        XCTAssertEqual(RequirementContext.unknown.line, 0)
        XCTAssertEqual(RequirementContext.unknown.function, "")
    }

    func test_requirement_success() {
        do {
            try Requirement("Non-zero value") { $0 != 0 }.validate(14)
        } catch {
            XCTFail("Unexpected failure")
        }
    }

    func test_requirement_callAsFunction_validatesValue() {
        let requirement = Requirement<Int, Never>("Non-zero value") { $0 != 0 }

        XCTAssertNoThrow(try requirement(14))

        do {
            try requirement(0)
            XCTFail("Expected an error")
        } catch {
            guard
                case let RequirementError.unsatisfied(description, input, context) = error
            else {
                return XCTFail("Unexpected validation error")
            }

            XCTAssertEqual(description, "Non-zero value")
            XCTAssertEqual(input, 0)
            XCTAssertEqual(context, .unknown)
        }
    }

    func test_requirement_callAsFunction_evaluationFailure_hasUnknownContext() {
        enum TestError: Error { case brokenCondition }

        let body = { @Sendable (_: Int) throws(TestError) -> Bool in
            throw TestError.brokenCondition
        }
        let requirement = Requirement("Any value", body)

        do {
            try requirement(14)
            XCTFail("Expected an error")
        } catch {
            guard
                case let RequirementError.evaluationFailed(_, nestedError, context) = error
            else {
                return XCTFail("Unexpected validation error")
            }

            XCTAssertEqual(context, .unknown)
            guard case TestError.brokenCondition = nestedError else {
                return XCTFail("Unexpected nested error")
            }
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
        let expectedFile = #fileID
        let expectedFunction = #function
        var expectedLine = 0

        do {
            expectedLine = #line + 1
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
            XCTAssertEqual(context.file, expectedFile)
            XCTAssertEqual(context.line, expectedLine)
            XCTAssertEqual(context.function, expectedFunction)
        }
    }

    func test_requirement_unsatisfiedCondition_customContext() {
        let requirement = Requirement<Int, Never>("Non-zero value") { $0 != 0 }
        let expectedContext = RequirementContext(
            file: "CustomFile.swift",
            line: 42,
            function: "customFunction()"
        )

        do {
            _ = try requirement.validate(
                file: expectedContext.file,
                line: expectedContext.line,
                function: expectedContext.function,
                0
            )
            XCTFail("Expected an error")
        } catch {
            guard
                case let RequirementError.unsatisfied(_, _, context) = error
            else {
                return XCTFail("Unexpected validation error")
            }

            XCTAssertEqual(context, expectedContext)
        }
    }

    func test_requirementError_diagnosticsAndConditionalConformances() throws {
        func requireSendable<T: Sendable>(_: T) {}

        let context = RequirementContext(file: "File.swift", line: 12, function: "test()")
        let unsatisfied = RequirementError<Int, ComparableError>.unsatisfied(
            description: "Value is positive",
            input: -1,
            context: context
        )
        let evaluationFailed = RequirementError<Int, ComparableError>.evaluationFailed(
            description: "Value is available",
            error: ComparableError(message: "Unavailable"),
            context: context
        )

        XCTAssertEqual(
            unsatisfied.description,
            "Unsatisfied requirement: Value is positive. Rejected input: -1"
        )
        XCTAssertEqual(unsatisfied.errorDescription, unsatisfied.description)
        XCTAssertEqual(
            evaluationFailed.description,
            "Requirement evaluation failed: Value is available. Error: ComparableError(message: \"Unavailable\")"
        )
        XCTAssertEqual(unsatisfied, unsatisfied)
        XCTAssertEqual(Set([unsatisfied, unsatisfied]).count, 1)
        XCTAssertNoThrow(try JSONEncoder().encode(unsatisfied))
        requireSendable(unsatisfied)
    }

    func test_requirement_isSatisfied() {
        let requirement = Requirement<Int, Never>("Non-zero value") { $0 != 0 }

        XCTAssertTrue(requirement.isSatisfied(by: 1))
        XCTAssertFalse(requirement.isSatisfied(by: 0))
    }
}
