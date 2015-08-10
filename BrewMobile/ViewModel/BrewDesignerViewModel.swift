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
    var hasPhasesSignal: RACSignal!
    var validBeerSignal: RACSignal!
    var cocoaActionSync: CocoaAction!

    var phases = PhaseArray()
    
    let nameProperty = MutableProperty<String>("")
    let startTimeProperty = MutableProperty<String>("")

    var brewStateProperty = MutableProperty(BrewState())

    var newState: BrewState = BrewState()
    
    init(brewManager: BrewManager) {
        self.brewManager = brewManager
        
        super.init()

        brewStateProperty = MutableProperty(BrewState(name: nameProperty.value, startTime: startTimeProperty.value, phases: self.phases, paused: false, inProgress: false))
        brewStateProperty.value.name <~ nameProperty
        brewStateProperty.value.startTime <~ startTimeProperty
        
        hasPhasesSignal = RACObserve(self, "phases").map {
            (aPhases: AnyObject!) -> AnyObject! in
            let phasesArray = aPhases as! PhaseArray
            return phasesArray.count > 0
        }.distinctUntilChanged()
        
        let validBeerNameSignal = RACObserve(self, "name").map {
            (aName: AnyObject!) -> AnyObject! in
            let nameText = aName as! String
            return count(nameText) > 0
        }.distinctUntilChanged()
        
        validBeerSignal = RACSignal.combineLatest([validBeerNameSignal, hasPhasesSignal]).map {
            (tuple: AnyObject!) -> AnyObject in
            let validBeer = tuple as! RACTuple
            
            let validName = validBeer.first as! Bool
            let validPhases = validBeer.second as! Bool
            
            return validName && validPhases
        }
        
        cocoaActionSync = CocoaAction(brewManager.syncBrewAction, input: brewStateProperty.value)
    }
    
}
