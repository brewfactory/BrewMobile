//
//  BrewState.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 14/09/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import SwiftyJSON

// MARK: Equatable

func == (left: BrewState, right: BrewState) -> Bool {
    let phasesAreIdentical = { () -> Bool in
        for i in 0...left.phases.value.count - 1 {
            if left.phases.value[i] != right.phases.value[i] {
                return false
            }
        }
        return true
    }()
    
    return (left.name.value == right.name.value) && (left.startTime.value == right.startTime.value) && phasesAreIdentical && (left.paused.value == right.paused.value) && (left.inProgress.value == right.inProgress.value)
}

final class BrewState: Equatable, JSONDecodable, JSONEncodable  {
    var name: MutableProperty<String>
    var startTime: MutableProperty<String>
    var phases: MutableProperty<PhaseArray>
    var paused: MutableProperty<Bool>
    var inProgress: MutableProperty<Bool>
    
    init() {
        name = MutableProperty("")
        startTime = MutableProperty("")
        phases = MutableProperty(PhaseArray())
        paused = MutableProperty(false)
        inProgress = MutableProperty(false)
    }
    
    init(name: String, startTime: String, phases: PhaseArray, paused: Bool, inProgress: Bool) {
        self.name = MutableProperty(name)
        self.startTime = MutableProperty(startTime)
        self.phases = MutableProperty(phases)
        self.paused = MutableProperty(paused)
        self.inProgress = MutableProperty(inProgress)
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
       
        brew["name"] = object.name.value
        brew["startTime"] = object.startTime.value
        
        brew["phases"] = object.phases.value.map { (BrewPhase phase) -> AnyObject in
            return BrewPhase.encode(phase).value!
        }
        
        return Result.success(brew)
    }

}
