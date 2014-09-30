//
//  BrewPhaseTestCase.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 18/09/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit
import XCTest

class BrewPhaseTestCase: XCTestCase {
    var brewPhase = BrewPhase()
   
    override func setUp() {
        super.setUp()
        
        brewPhase = BrewPhase(jobEnd: "09:55", min: 30, temp: 45.0, tempReached: false, inProgress: true)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testJobEnd() {
        XCTAssertNotNil(brewPhase.jobEnd, "should have jobEnd")
        XCTAssertTrue(brewPhase.jobEnd == "09:55", "expected to be equal")
    }
    
    func testMin() {
        XCTAssertNotNil(brewPhase.min, "should have min")
        XCTAssertTrue(brewPhase.min == 30, "expected to be equal")
    }
    
    func testTemp() {
        XCTAssertNotNil(brewPhase.temp, "should have temp")
        XCTAssertTrue(brewPhase.temp == 45.0, "expected to be equal")
    }
    
    func testTempReached() {
        XCTAssertNotNil(brewPhase.tempReached, "should have tempReached")
        XCTAssertFalse(brewPhase.tempReached, "expected to be false")
    }
    
    func testInProgress() {
        XCTAssertNotNil(brewPhase.inProgress, "should have inProgress")
        XCTAssertTrue(brewPhase.inProgress, "expected to be true")
    }

}
