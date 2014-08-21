//
//  ContentParser.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 19/08/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation


typealias JSON = AnyObject
typealias JSONDictionary = Dictionary<String, JSON>
typealias JSONArray = Array<JSON>

func parseBrewState(brew: AnyObject) -> BrewState? {
    if let json = brew as? JSONDictionary {
        if let name = json["name"] as AnyObject? as? String {
            if let startTime = json["startTime"] as AnyObject? as? String {
                if let phases = json["phases"] as AnyObject? as? JSONArray {
                    if let paused = json["paused"] as AnyObject? as? Bool {
                        if let inProgress = json["inProgress"] as AnyObject? as? Bool {
                            let parsedPhases = { (phases: JSONArray) -> Array<BrewPhase> in
                                var newPhases: Array<BrewPhase> = []

                                for rawPhase: JSON in phases {
                                    let brewPhase = parseBrewPhase(rawPhase)
                                    newPhases.append(brewPhase!)
                                }
                                return newPhases
                            }
                            let brewState = BrewState(name: name, startTime: formatDate(startTime), phases: parsedPhases(phases), paused: paused, inProgress: inProgress)
                            return brewState
                        }
                    }
                }
            }
        }
    }
    return BrewState()
}

func parseBrewPhase(brew: AnyObject) -> BrewPhase? {
    if let json = brew as? JSONDictionary {
            if let min = json["min"] as AnyObject? as? Int {
                if let temp = json["temp"] as AnyObject? as? Float {
                    if let tempReached = json["tempReached"] as AnyObject? as? Bool {
                        if let inProgress = json["inProgress"] as AnyObject? as? Bool {
                            var jobEnd = ""
                            if let jobEndDate = json["jobEnd"] as AnyObject? as? String {
                                jobEnd = formatDate(jobEndDate)
                            }
                            let brewPhase = BrewPhase(jobEnd: jobEnd, min: min, temp: temp, tempReached: tempReached, inProgress: inProgress)
                            return brewPhase
                        }
                    }
                }
            }
    }
    return BrewPhase()
}
 
func formatDate(startTimeString: String) -> String {
    let isoDateFormatter = ISO8601DateFormatter()
    let formattedDate = isoDateFormatter.dateFromString(startTimeString)
    let dateStringFormatter = NSDateFormatter()
    dateStringFormatter.dateFormat = "HH:mm"
    let dateString = dateStringFormatter.stringFromDate(formattedDate!)
            
    return dateString
}