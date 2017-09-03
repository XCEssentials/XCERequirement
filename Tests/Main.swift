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

class Main: XCTestCase
{
    func testFalseClosure()
    {
        do
        {
            try Require("Non-zero").isFalse { 14 == 0 }
            print("YES")
        }
        catch
        {
            print("NO")
            XCTFail()
        }
    }
}
