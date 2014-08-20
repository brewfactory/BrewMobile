//
//  Brew.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 19/08/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation

typealias PhaseArray = Array<BrewPhase>

enum State: Int {
    case INACTIVE = 0
    case HEATING
    case ACTIVE
    case FINISHED
    
    func stateDescription() -> String {
        switch self {
        case .INACTIVE:
            return "inactive"
        case .HEATING:
            return "heating"
        case .ACTIVE:
            return "active"
        case .FINISHED:
            return "finished"
        default:
            return String(self.toRaw())
        }
    }
}

class Brew {
    var inProgress: Bool
    
    init () {
        inProgress = false
    }
    
    init(inProgress: Bool) {
        self.inProgress = inProgress
    }
}

class BrewState: Brew {
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
}

class BrewPhase: Brew {
    var jobEnd: String
    var min: Int
    var temp: Int
    var tempReached: Bool
    var state: State
    
    override init() {
        jobEnd = ""
        min = 0
        temp = 0
        tempReached = false
        state = State.INACTIVE
        super.init()
    }
    
    init(jobEnd: String, min: Int, temp: Int, tempReached: Bool, inProgress: Bool) {
        self.jobEnd = jobEnd
        self.min = min
        self.temp = temp
        self.tempReached = tempReached
       
        self.state = { () -> State in
            switch (inProgress, tempReached)  {
            case (true, false):
                return State.HEATING
            case (true, true):
                return State.ACTIVE
            case (false, true):
                return State.FINISHED
            case (false, false):
                fallthrough
            default:
                return State.INACTIVE
            }
        } ()
        
        super.init(inProgress: inProgress)
    }
}
