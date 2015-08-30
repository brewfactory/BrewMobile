//
//  BrewStateTestCase.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 18/09/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit
import XCTest

class BrewStateTestCase: XCTestCase {
    var brewState = BrewState()
    var brewPhase = BrewPhase()

    override func setUp() {
        super.setUp()
        
        brewPhase = BrewPhase(jobEnd: ContentParser.formatDate("2014-08-03T11:55:00.000Z"), min: 10, temp: 70, tempReached: false, inProgress: true)
        brewState = BrewState(name: "Very IPA", startTime: "10:30", phases: [brewPhase], paused: false, inProgress: true)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testName() {
        XCTAssertNotNil(brewState.name.value, "should have name")
        XCTAssertTrue(brewState.name.value == "Very IPA", "expected to be equal")
    }
    
    func testStartTime() {
        XCTAssertNotNil(brewState.startTime.value, "should have startTime")
        XCTAssertTrue(brewState.startTime.value == "10:30", "expected to be equal")
    }
    
    func testPhases() {
        XCTAssertEqual(brewState.phases.value[0] as BrewPhase, brewPhase, "expected to be equal")
    }
    
    func testPaused() {
        XCTAssertNotNil(brewState.paused.value, "should have paused")
        XCTAssertFalse(brewState.paused.value, "expected to be false")
    }
    
    func testInProgress() {
        XCTAssertNotNil(brewState.inProgress.value, "should have inProgress")
        XCTAssertTrue(brewState.inProgress.value, "expected to be true")
    }


}
