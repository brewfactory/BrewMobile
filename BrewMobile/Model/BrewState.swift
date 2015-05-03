//
//  BrewState.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 14/09/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation
import Result
import SwiftyJSON

// MARK: Equatable

func == (left: BrewState, right: BrewState) -> Bool {
    let phasesAreIdentical = { () -> Bool in
        for i in 0...left.phases.count - 1 {
            if left.phases[i] != right.phases[i] {
                return false
            }
        }
        return true
    }()
    
    return (left.name == right.name) && (left.startTime == right.startTime) && phasesAreIdentical && (left.paused == right.paused) && (left.inProgress == right.inProgress)
}

final class BrewState: Equatable, JSONDecodable, JSONEncodable  {
    var name: String
    var startTime: String
    var phases: PhaseArray
    var paused: Bool
    var inProgress: Bool
    
    init() {
        name = ""
        startTime = ""
        phases = PhaseArray()
        paused = false
        inProgress = false
    }
    
    init(name: String, startTime: String, phases: PhaseArray, paused: Bool, inProgress: Bool) {
        self.name = name
        self.startTime = startTime
        self.phases = phases
        self.paused = paused
        self.inProgress = inProgress
    }

    // MARK: JSONDecodable

    class func decode(json: JSON) -> Result<BrewState, NSError> {
        return Result.success(BrewState(
            name: json["name"].stringValue,
            startTime: ContentParser.formatDate(json["startTime"].stringValue),
            phases: json["phases"].arrayValue.map { (JSON rawPhase) -> BrewPhase in
                return ContentParser.parseBrewPhase(rawPhase)
            },
            paused: json["paused"].boolValue,
            inProgress: json["inProgress"].boolValue)
        )
    }

    // MARK: JSONEncodable
    
    class func encode(object: BrewState) -> Result<AnyObject, NSError> {
        var brew = Dictionary<String, AnyObject>()
       
        brew["name"] = object.name
        brew["startTime"] = object.startTime
        
        brew["phases"] = object.phases.map { (BrewPhase phase) -> AnyObject in
            return BrewPhase.encode(phase).value!
        }
        
        return Result.success(brew)
    }

}
