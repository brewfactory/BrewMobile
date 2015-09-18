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

    let phases = MutableProperty(PhaseArray())
    
    let name = MutableProperty("")
    let startTime = MutableProperty("")
    let brewState = MutableProperty(BrewState())
    let hasPhases = MutableProperty(false)
    let validName = MutableProperty(false)
    let validBeer = MutableProperty(false)

    var newState: BrewState = BrewState()
    
    init(brewManager: BrewManager) {
        self.brewManager = brewManager
        super.init()

        brewState.value = (BrewState(name: name, startTime: startTime, phases: self.phases, paused: false, inProgress: false))

        hasPhases <~ self.phases.producer
            .flatMap(.Concat) { SignalProducer(value: $0.count > 0) }
        validName <~ self.brewState.producer
            .flatMap(.Concat) { SignalProducer(value: $0.name.value.characters.count > 0) }
        validBeer <~ combineLatest(hasPhases.producer, validName.producer)
            .map { $0 && $1 }

        cocoaActionSync = CocoaAction(brewManager.syncBrewAction, input: brewState.value)
    }
    
}
