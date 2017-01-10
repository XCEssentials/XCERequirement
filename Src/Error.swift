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
struct RequirementNotSatisfied: Error
{
    public
    let requirement: String
    
    public
    let input: Any
    
    //===
    
    init(_ requirement: String, input: Any)
    {
        self.requirement = requirement
        self.input = input
    }
    
    //===
    
    public
    var localizedDescription: String
    {
        return
            "Requirement [ " + requirement +
            " ] is not satisfied with input <\(input)>."
    }
}
