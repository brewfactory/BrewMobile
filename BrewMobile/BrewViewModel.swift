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
    let hasPhasesSignal: RACSignal!
    let validBeerSignal: RACSignal!
    let tempChangedSignal: RACSignal!
    let brewChangedSignal: RACSignal!
    let socketErrorSignal: RACSignal!

    let brewManager: BrewManager
    var name = ""
    var phases = PhaseArray()
    var startTime = ""
    var actState = BrewState()
    var actTemp = 0.0

    init(brewManager: BrewManager) {
        
        self.brewManager = brewManager
    
        super.init()
        
        //MARK: Brew
        
        self.brewManager.connectToHost().deliverOn(RACScheduler.mainThreadScheduler()).subscribeNext({
            (next: AnyObject!) -> Void in
            let
            }, error: { (error: NSError!) -> Void in
            //error
        })
        
        //MARK: Designer

        hasPhasesSignal = RACObserve(self, "phases").map {
            (aPhases: AnyObject!) -> AnyObject! in
            let phasesArray = aPhases as PhaseArray
            return phasesArray.count > 0
        }.distinctUntilChanged()

        let validBeerNameSignal = RACObserve(self, "name").map {
            (aName: AnyObject!) -> AnyObject! in
            let nameText = aName as String
            return countElements(nameText) > 0
        }.distinctUntilChanged()

        validBeerSignal = RACSignal.combineLatest([validBeerNameSignal, hasPhasesSignal]).map {
            (tuple: AnyObject!) -> AnyObject in
            let validBeer = tuple as RACTuple

            let validName = validBeer.first as Bool
            let validPhases = validBeer.second as Bool

            return validName && validPhases
        }

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