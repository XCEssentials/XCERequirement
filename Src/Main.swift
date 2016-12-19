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
struct Requirement<Input>
{
    public
    let title: String
    
    public
    let check: Check<Input>
    
    //===
    
    public
    init(_ title: String, _ check: @escaping Check<Input>)
    {
        self.title = title
        self.check = check
    }
}

//=== MARK: Compute properties (internal)

extension Requirement
{
    var errorMessage: String
    {
        return "Requirement [ " + title + " ] is not fulfilled."
    }
}
