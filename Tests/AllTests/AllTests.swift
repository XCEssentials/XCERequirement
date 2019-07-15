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
    func testSimpleRequirement()
    {
        do
        {
            try Requirement("Non-zero value"){ $0 != 0 }.validate(14)
        }
        catch
        {
            XCTFail("Should never get here")
        }
    }
}
