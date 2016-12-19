//
//  Error.swift
//  MKHRequirement
//
//  Created by Maxim Khatskevich on 12/19/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
struct RequirementNotFulfilled: Error
{
    public
    let message: String
    
    //===
    
    init(_ message: String)
    {
        self.message = message
    }
}

//===

public
extension Requirement
{
    func verify(_ input: Input) throws
    {
        if
            !check(input)
        {
            throw RequirementNotFulfilled(errorMessage)
        }
    }
}
