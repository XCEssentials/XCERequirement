//
//  Main.swift
//  MKHRequirement
//
//  Created by Maxim Khatskevich on 12/19/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import Foundation

//===

public
typealias RequirementBody<Input> = (_ input: Input) -> Bool

//===

public
struct Requirement<Input>
{
    public
    let title: String
    
    let body: RequirementBody<Input>
    
    //===
    
    public
    init(_ title: String, _ body: @escaping RequirementBody<Input>)
    {
        self.title = title
        self.body = body
    }
    
    //===
    
    public
    func isSatisfied(with input: Input) -> Bool
    {
        return body(input)
    }
    
    public
    func check(with input: Input) throws
    {
        if
            !body(input)
        {
            throw RequirementNotSatisfied(title, input: input)
        }
    }
}
