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
    var actTemp: Float = 0.0

    init(brewManager: BrewManager) {
        
        self.brewManager = brewManager
    
        super.init()
        self.brewManager.connectToHost()
       
        //MARK: Brew
        
        stopCommand = RACCommand() {
            Void -> RACSignal in
            return brewManager.stopBrewCommand.execute(nil).deliverOn(RACScheduler.mainThreadScheduler())
        }
        
        tempChangedSignal = self.brewManager.tempChangedSignal.map {
            (any: AnyObject!) -> AnyObject! in
            if let anyDict = any as? Dictionary<String, Float> {
                if let temp = anyDict[tempChangedEvent] {
                    return temp
                }
            }
            return 0
        }.deliverOn(RACScheduler.mainThreadScheduler())
        
        brewChangedSignal = self.brewManager.brewChangedSignal.map {
            (any: AnyObject!) -> AnyObject! in
            if let anyDict = any as? Dictionary<String, BrewState> {
                if let brew = anyDict[brewChangedEvent] {
                    self.actState = brew
                    return brew
                }
            }
            return nil
        }.deliverOn(RACScheduler.mainThreadScheduler())
        
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
    }

}