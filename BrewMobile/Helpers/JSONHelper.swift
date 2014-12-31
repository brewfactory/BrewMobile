//
//  JSONHelper.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 14/09/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation
import LlamaKit
import SwiftyJSON

typealias JSONDictionary = [String: JSON]

// MARK: JSONDecodable

protocol JSONDecodable {
    class func decode(json: JSON) -> Result<Self>
}

// MARK: JSONEncodable

protocol JSONEncodable {
    class func encode(object: Self) -> Result<AnyObject>
}
