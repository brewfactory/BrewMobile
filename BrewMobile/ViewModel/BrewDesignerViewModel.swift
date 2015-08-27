//
//  BrewDesignerViewModel.swift
//  BrewMobile
//
//  Created by Agnes Vasarhelyi on 01/03/15.
//  Copyright (c) 2015 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation
import ReactiveCocoa

class BrewDesignerViewModel : NSObject {

    let brewManager: BrewManager
    
    var cocoaActionSync: CocoaAction!

    var phases = PhaseArray()
    
    let nameProperty = MutableProperty("")
    let startTimeProperty = MutableProperty("")
    var brewStateProperty = MutableProperty(BrewState())
    var hasPhasesProperty = MutableProperty(false)
    var validNameProperty = MutableProperty(false)
    var validBeerProperty = MutableProperty(false)

    var newState: BrewState = BrewState()
    
    init(brewManager: BrewManager) {
        self.brewManager = brewManager
        super.init()

        brewStateProperty = MutableProperty(BrewState(name: nameProperty.value, startTime: startTimeProperty.value, phases: self.phases, paused: false, inProgress: false))
        brewStateProperty.value.name <~ nameProperty
        brewStateProperty.value.startTime <~ startTimeProperty

        hasPhasesProperty = MutableProperty(self.phases.count > 0)
        validNameProperty = MutableProperty(count(brewStateProperty.value.name.value) > 0)
        validBeerProperty = MutableProperty(hasPhasesProperty.value && validNameProperty.value)

        cocoaActionSync = CocoaAction(brewManager.syncBrewAction, input: brewStateProperty.value)
    }
    
}
