//
//  BrewState.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 14/09/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation
import LlamaKit
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

    class func decode(json: JSON) -> Result<BrewState> {
        let parsedPhases = { (phases: Array<JSON>) -> PhaseArray in
            var newPhases: PhaseArray = []
        
            for rawPhase: JSON in phases {
                let brewPhase = ContentParser.parseBrewPhase(rawPhase)
                newPhases.append(brewPhase)
            }
            return newPhases
        } (json["phases"].arrayValue)
        
        return success(BrewState(
            name: json["name"].stringValue,
            startTime: ContentParser.formatDate(json["startTime"].stringValue),
            phases: parsedPhases,
            paused: json["paused"].boolValue,
            inProgress: json["inProgress"].boolValue)
        )
    }

    // MARK: JSONEncodable
    
    class func encode(object: BrewState) -> Result<AnyObject> {
        var brew = Dictionary<String, AnyObject>()
       
        brew["name"] = object.name
        brew["startTime"] = object.startTime
        
        var encodedPhases = Array<AnyObject>()
        for phase: BrewPhase in object.phases {
            encodedPhases.append(BrewPhase.encode(phase).value()!)
        }
        
        brew["phases"] = encodedPhases
        return success(brew)
    }

}
