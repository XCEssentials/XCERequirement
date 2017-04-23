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
    let r = Require<Int>("Non-zero") { $0 != 0 }
    
    //===
    
    func testBasic()
    {
        if
            r.isFulfilled(with: 14)
        {
            print("\(r.title) -> YES")
        }
        else
        {
            print("\(r.title) -> NO")
            XCTFail()
        }
    }
    
    func testExtra()
    {
        do
        {
            try r.check(with: 0)
            XCTFail() // should never get to this point
        }
        catch
        {
            print(error)
        }
    }
}
