//
//  BrewState.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 14/09/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation

class BrewState: Brew  {
    var name: String
    var startTime: String
    var phases: PhaseArray
    var paused: Bool
    
    override init() {
        name = ""
        startTime = ""
        phases = PhaseArray()
        paused = false
        super.init()
    }
    
    init(name: String, startTime: String, phases: PhaseArray, paused: Bool, inProgress: Bool) {
        self.name = name
        self.startTime = startTime
        self.phases = phases
        self.paused = paused
        super.init(inProgress: inProgress)
    }
    
    class func create(name: String)(startTime: String)(phases: JSONArray)(paused: Bool)(inProgress: Bool) -> BrewState {
        let parsedPhases = { (phases: JSONArray) -> PhaseArray in
            var newPhases: PhaseArray = []
            
            for rawPhase: JSON in phases {
                if let brewPhase = parseBrewPhase(rawPhase) {
                    newPhases.append(brewPhase)
                }
            }
            return newPhases
            }(phases)
        return BrewState(name: name, startTime: formatDate(startTime), phases: parsedPhases, paused: paused, inProgress: inProgress)
    }


    // MARK: JSONDecodable

    override class func decode(json: JSON) -> BrewState? {
        return JSONDictObject(json) >>> { brew in
            BrewState.create <^>
                brew["name"]       >>> JSONString      <*>
                ((brew["startTime"] >>> JSONString) ?? "") <*>
                brew["phases"]     >>> JSONArrayObject <*>
                brew["paused"]     >>> JSONBool        <*>
                brew["inProgress"] >>> JSONBool
        }
    }
}
