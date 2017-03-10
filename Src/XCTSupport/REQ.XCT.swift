//
//  ExtraXCT.swift
//  MKHRequirement
//
//  Created by Maxim Khatskevich on 12/20/16.
//  Copyright © 2016 Maxim Khatskevich. All rights reserved.
//

import MKHRequirement
import XCTest

//===

public
enum RXCT {}

//===

public
extension RXCT
{
    static
    func value<Output>(
        _ description: String,
        file: StaticString = #file,
        line: UInt = #line,
        _ body: () -> Output?
        ) throws -> Output
    {
        do
        {
            return try REQ.value(description, body)
        }
        catch
        {
            XCTFail(error.localizedDescription, file: file, line: line)
            throw error
        }
    }
    
    static
    func isTrue(
        _ description: String,
        file: StaticString = #file,
        line: UInt = #line,
        _ body: () -> Bool
        ) throws
    {
        do
        {
            try REQ.isTrue(description, body)
        }
        catch
        {
            XCTFail(error.localizedDescription, file: file, line: line)
            throw error
        }
    }
    
    static
    func isNil(
        _ description: String,
        file: StaticString = #file,
        line: UInt = #line,
        _ body: () -> Any?
        ) throws
    {
        do
        {
            try REQ.isNil(description, body)
        }
        catch
        {
            XCTFail(error.localizedDescription, file: file, line: line)
            throw error
        }
    }
    
    static
    func isNotNil(
        _ description: String,
        file: StaticString = #file,
        line: UInt = #line,
        _ body: () -> Any?
        ) throws
    {
        do
        {
            try REQ.isNotNil(description, body)
        }
        catch
        {
            XCTFail(error.localizedDescription, file: file, line: line)
            throw error
        }
    }
}
