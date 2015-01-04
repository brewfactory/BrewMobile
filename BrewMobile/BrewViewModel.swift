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
    let validBeerSignal: RACSignal!
    let brewManager: BrewManager
    var name: String!
    var phases: PhaseArray!
    var startTime: String!
    
    init(brewManager: BrewManager) {
        
        self.brewManager = brewManager
    
        super.init()

        let validBeerNameSignal = self.rac_valuesForKeyPath("name", observer: self).map {
            (name: AnyObject!) -> NSNumber in
            let nameText = name as String
            return countElements(nameText) > 0
        }.distinctUntilChanged()
        
        let hasPhasesSignal = self.rac_valuesForKeyPath("name", observer: self).map {
            (phases: AnyObject!) -> NSNumber in
            let phasesArray = phases as PhaseArray
            return phasesArray.count > 0
            }.distinctUntilChanged()
        
        validBeerSignal = RACSignal.merge([validBeerNameSignal, hasPhasesSignal])
        
        syncCommand = RACCommand(enabled: validBeerNameSignal) {
            (any:AnyObject!) -> RACSignal in
            return RACSignal()
        }
    }
    
    private func syncSignal() -> RACSignal {
//        return brewManager.syncBrewSignal(searchText).doNextAs {
//            (results: FlickrSearchResults) -> () in
//            let viewModel = SearchResultsViewModel(services: self.services, searchResults: results)
//            self.services.pushViewModel(viewModel)
//            self.addToSearchHistory(results)
//        }
        return RACSignal()
    }
}