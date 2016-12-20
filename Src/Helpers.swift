//
//  Helpers.swift
//  MKHRequirement
//
//  Created by Maxim Khatskevich on 12/20/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

public
typealias Require<Input> = Requirement<Input>

public
extension Requirement
{
    init()
    {
        self.init("Accept everything") { _ in return true }
    }
}
