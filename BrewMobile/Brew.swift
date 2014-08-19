//
//  Brew.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 19/08/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation

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

class BrewPhase {
    var jobEnd: String!
    var min: Int!
    var temp: Int!
    var tempReached: Bool!
    var inProgress: Bool!
    
    init() {
        jobEnd = ""
        min = 0
        temp = 0
        tempReached = false
        inProgress = false
    }
}

class BrewState {
    var name: String!
    var startTime: String!
    var phases: Array<BrewPhase>!
    var paused: Bool!
    var inProgress: Bool!
    
    init() {
        name = ""
        startTime = ""
        phases = []
        paused = false
        inProgress = false
    }
}
