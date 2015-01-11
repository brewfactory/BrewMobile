//
//  BrewViewModel.swift
//  BrewMobile
//
//  Created by Agnes Vasarhelyi on 04/01/15.
//  Copyright (c) 2015 Ágnes Vásárhelyi. All rights reserved.
//

import Foundation
import ReactiveCocoa

class BrewViewModel : NSObject {
    let syncCommand: RACCommand!
    let stopCommand: RACCommand!
    let validBeerSignal: RACSignal!
    let hasPhasesSignal: RACSignal!
    let brewManager: BrewManager
    var name = ""
    var phases = PhaseArray()
    var startTime = ""
    
    init(brewManager: BrewManager) {
        
        self.brewManager = brewManager
    
        super.init()

        let validBeerNameSignal = self.rac_valuesForKeyPath("name", observer: self).map {
            (name: AnyObject!) -> AnyObject! in
            let nameText = name as String
            return countElements(nameText) > 3
        }.distinctUntilChanged()
        
        let hasPhasesSignal = self.rac_valuesForKeyPath("phases", observer: self).map {
            (phases: AnyObject!) -> AnyObject! in
            let phasesArray = phases as PhaseArray
            return phasesArray.count > 0
        }.distinctUntilChanged()
        
        validBeerSignal = RACSignal.merge([validBeerNameSignal, hasPhasesSignal])

        syncCommand = RACCommand() {
            Void -> RACSignal in
            let brewState = BrewState(name: self.name, startTime: self.startTime, phases: self.phases, paused: false, inProgress: false)
            return brewManager.syncBrewCommand.execute(BrewState.encode(brewState).value()!)
        }
        
        stopCommand = RACCommand() {
            Void -> RACSignal in
            return brewManager.stopBrewSignal
        }
    }

}