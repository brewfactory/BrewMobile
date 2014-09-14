//
//  Brew.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 19/08/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation

class Brew : JSONDecodable {
    var inProgress: Bool
    
    init () {
        inProgress = false
    }
    
    init(inProgress: Bool) {
        self.inProgress = inProgress
    }
    
    // MARK: JSONDecodable

    class func decode(json: JSON) -> Self? {
        return nil
    }
}
