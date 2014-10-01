//
//  BrewPhase.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 14/09/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation
import UIKit

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

// MARK: Equatable

func == (left: BrewPhase, right: BrewPhase) -> Bool {
    return (left.jobEnd == right.jobEnd) && (left.min == right.min) && (left.temp == right.temp) && (left.tempReached == right.tempReached) && (left.inProgress == right.inProgress)
}

class BrewPhase: Brew, Equatable {
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
    
    class func create(jobEnd: String)(min: Int)(temp: Float)(tempReached: Bool)(inProgress: Bool) -> BrewPhase {
        return BrewPhase(jobEnd: formatDate(jobEnd), min: min, temp: temp, tempReached: tempReached, inProgress: inProgress)
    }
    
    // MARK: JSONDecodable
    
    override class func decode(json: JSON) -> BrewPhase? {
        if let decodedBrewPhaseObject = (JSONDictObject(json) >>> { brew in
            BrewPhase.create <^>
                ((brew["jobEnd"] >>> JSONString) ?? "") <*>
                brew["min"]             >>> JSONInt     <*>
                brew["temp"]            >>> JSONFloat   <*>
                brew["tempReached"]     >>> JSONBool    <*>
                brew["inProgress"]      >>> JSONBool
            }) {
            return decodedBrewPhaseObject
        } else {
            return BrewPhase()
        }
    }
    
}
