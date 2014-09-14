//
//  JSONHelper.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 14/09/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation

typealias JSON = AnyObject
typealias JSONDictionary = [String: JSON]
typealias JSONArray = [JSON]

// MARK: Operators

infix operator >>> { associativity left precedence 150 }
infix operator <^> { associativity left }
infix operator <*> { associativity left }

func >>><A, B>(a: A?, f: A -> B?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .None
    }
}

func <^><A, B>(f: A -> B, a: A?) -> B? {
    if let x = a {
        return f(x)
    } else {
        return .None
    }
}

func <*><A, B>(f: (A -> B)?, a: A?) -> B? {
    if let x = a {
        if let fx = f {
            return fx(x)
        }
    }
    return .None
}

// MARK: JSON type checking

func JSONString(object: JSON) -> String? {
    return object as? String
}

func JSONInt(object: JSON) -> Int? {
    return object as? Int
}

func JSONFloat(object: JSON) -> Float? {
    return object as? Float
}

func JSONBool(object: JSON) -> Bool? {
    return object as? Bool
}

func JSONDictObject(object: JSON) -> JSONDictionary? {
    return object as? JSONDictionary
}

func JSONArrayObject(object: JSON) -> JSONArray? {
    return object as? JSONArray
}

// MARK: JSONDecodable

protocol JSONDecodable {
    class func decode(json: JSON) -> Self?
}
