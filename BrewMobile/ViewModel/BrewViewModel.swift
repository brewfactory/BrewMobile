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
    var cocoaActionStop: CocoaAction!
    let tempChanged = MutableProperty<Float>(0.0)
    let brewChanged = MutableProperty(BrewState())
    let pwmChanged = MutableProperty<Float>(0.0)

    let brewManager: BrewManager

    init(brewManager: BrewManager) {        
        self.brewManager = brewManager
        super.init()

        self.brewManager.connectToHost()

        cocoaActionStop = CocoaAction(brewManager.stopBrewAction, input: ())

        tempChanged <~ self.brewManager.tempChanged
        brewChanged <~ self.brewManager.brewChanged
        pwmChanged <~ self.brewManager.pwmChanged
    }

}
