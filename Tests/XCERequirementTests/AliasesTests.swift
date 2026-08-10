// SPDX-License-Identifier: MIT
// Copyright (c) 2016 Maxim Khatskevich

import XCTest
import XCERequirement

final class AliasesTests: XCTestCase {
    func test_aliases_requireConditionAndCheck() throws {
        let require: Require<Int, Never> = Require("Non-zero value") { $0 != 0 }
        let condition: Condition<Int, Never> = Condition("Positive value") { $0 > 0 }
        let check: Check<Int, Never> = Check("Even value") { $0.isMultiple(of: 2) }

        XCTAssertTrue(require.isSatisfied(by: 1))
        XCTAssertFalse(condition.isSatisfied(by: 0))
        XCTAssertTrue(check.isSatisfied(by: 2))
        try Check.that("Positive value", 1 > 0)
    }
}
