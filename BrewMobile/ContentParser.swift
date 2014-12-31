//
//  ContentParser.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 19/08/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation
import ISO8601
import SwiftyJSON
import LlamaKit

typealias PhaseArray = [BrewPhase]

class ContentParser {
    class func parseBrewState(brewJSON: JSON) -> BrewState {
        return BrewState.decode(brewJSON).value()!
    }
    
    class func parseBrewPhase(brewPhaseJSON: JSON) -> BrewPhase {
        return BrewPhase.decode(brewPhaseJSON).value()!
    }
    
    class func formatDate(dateString: String) -> String {
        if countElements(dateString) > 0 {
            let isoDateFormatter = ISO8601DateFormatter()
            let formattedDate = isoDateFormatter.dateFromString(dateString)
            let dateStringFormatter = NSDateFormatter()
            dateStringFormatter.dateFormat = "HH:mm"
            let formattedDateString = dateStringFormatter.stringFromDate(formattedDate!)
            
            return formattedDateString
        }
        return ""
    }

}
