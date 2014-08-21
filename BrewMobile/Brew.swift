//
//  Brew.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 19/08/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation
import UIKit

typealias PhaseArray = Array<BrewPhase>

enum State: Int {
    case INACTIVE = 0
    case HEATING
    case ACTIVE
    case FINISHED
    
    func stateDescription() -> String {
        switch self {
        case .INACTIVE:
            return ""
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
    
    func bgColor() -> UIColor {
        switch self {
        case .INACTIVE:
            return UIColor(red: 245.0 / 255.0, green:245.0 / 255.0, blue:245.0 / 255.0, alpha: 1.0)
        case .HEATING:
            return UIColor(red: 240.0 / 255.0,  green:173.0 / 255.0, blue:78.0 / 255.0, alpha: 1.0)
        case .ACTIVE:
            return UIColor(red: 66.0 / 255.0, green:139.0 / 255.0, blue:202.0 / 255.0, alpha: 1.0)
        case .FINISHED:
            return UIColor(red: 92.0 / 255.0, green:184.0 / 255.0, blue:92.0 / 255.0, alpha: 1.0)
        default:
            return UIColor.whiteColor()
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
    var temp: Float
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
    
    init(jobEnd: String, min: Int, temp: Float, tempReached: Bool, inProgress: Bool) {
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
