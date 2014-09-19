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
    let brewPhase = BrewPhase()

    override func setUp() {
        super.setUp()
        brewState = BrewState(name: "Very IPA", startTime: "10:30", phases: [brewPhase], paused: false, inProgress: true)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testName() {
        XCTAssertNotNil(brewState.name, "should have name")
        XCTAssertTrue(brewState.name == "Very IPA", "expected to be equal")
    }
    
    func testStartTime() {
        XCTAssertNotNil(brewState.startTime, "should have startTime")
        XCTAssertTrue(brewState.startTime == "10:30", "expected to be equal")
    }
    
    func testPhases() {
        XCTAssertEqual(brewState.phases[0] as BrewPhase, brewPhase, "expected to be equal")
    }
    
    func testPaused() {
        XCTAssertNotNil(brewState.paused, "should have paused")
        XCTAssertTrue(!brewState.paused, "expected to be false")
    }
    
    func testInProgress() {
        XCTAssertNotNil(brewState.inProgress, "should have inProgress")
        XCTAssertTrue(brewState.inProgress, "expected to be true")
    }


}
