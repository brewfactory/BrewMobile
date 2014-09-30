//
//  ContentParserTestCase.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 19/09/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit
import XCTest

class ContentParserTestCase: XCTestCase {
    var mockBrewState = BrewState()
    var mockBrewPhase = BrewPhase()

    override func setUp() {
        super.setUp()
        
        NSTimeZone.setDefaultTimeZone(NSTimeZone(forSecondsFromGMT: +0))

        mockBrewPhase = BrewPhase(jobEnd: formatDate("2014-08-03T11:55:00.000Z"), min: 10, temp: 70, tempReached: false, inProgress: true)
        mockBrewState = BrewState(name: "Very IPA", startTime: formatDate("2014-08-03T09:55:00.000Z"), phases: [mockBrewPhase], paused: false, inProgress: true)
    }
    
    override func tearDown() {
        NSTimeZone.setDefaultTimeZone(NSTimeZone(forSecondsFromGMT: +7200))

        super.tearDown()
    }
    
    //MARK: Testing BrewState object parsing
    func testParseBrewState() {
        let brewPhaseJSON = ["jobEnd" : "2014-08-03T11:55:00.000Z", "min" : 10, "temp" : 70, "tempReached" : 0, "inProgress" : 1]
        let brewStateJSON = ["name" : "Very IPA", "startTime" : "2014-08-03T09:55:00.000Z", "phases" : [brewPhaseJSON], "paused" : false, "inProgress" : true]
        if let brewState = parseBrewState(brewStateJSON) as BrewState! {
            XCTAssertEqual(brewState, mockBrewState, "expected to be equal")
        } else {
            XCTFail("Object could not be parsed as a BrewState")
        }
    }
    
    func testParseBrewStateWithEmptyJSON() {
        let JSON = ["name" : NSNull(), "startTime" : NSNull(), "phases" : NSNull(), "paused" : NSNull(), "inProgress" : NSNull()]
        if let brewState = parseBrewState(JSON) as BrewState! {
        } else {
            XCTFail("Object could not be parsed as a BrewState")
        }
    }
    
    func testParseBrewStateWithUnexpectedJSONStructure() {
        let JSON = ["phases" : NSNull(), "paused" : NSNull(), "inProgress" : NSNull()]
        if let brewstate = parseBrewState(JSON) as BrewState! {
        } else {
            XCTFail("Object could not be parsed as a BrewState")
        }
    }
    
    //MARK: Testing BrewPhase object parsing
    func testParseBrewPhase() {
        let JSON = ["jobEnd" : "2014-08-03T09:55:00.000Z", "min" : "100", "temp" : "76", "tempReached" : 0, "inProgress" : 1]
        if let brewPhase = parseBrewPhase(JSON) as BrewPhase! {
            
        } else {
            XCTFail("Object could not be parsed as a BrewPhase")
        }
        
        
    }
    
    func testParseBrewPhaseWithEmptyJSON() {
        let JSON = ["jobEnd" : NSNull(), "min" : NSNull(), "temp" : NSNull(), "tempReached" : NSNull(), "inProgress" : NSNull()]
        if let brewPhase = parseBrewPhase(JSON) as BrewPhase! {
        } else {
            XCTFail("Object could not be parsed as a BrewPhase")
        }
    }
    
    func testParseBrewPhaseWithUnexpectedJSONStructure() {
        let JSON = ["tempReached" : 0, "inProgress" : 1]
        if let brewPhase = parseBrewPhase(JSON) as BrewPhase! {
        } else {
            XCTFail("Object could not be parsed as a BrewPhase")
        }
    }

    func testFormatDate() {
        let originalDateString = "2014-08-03T09:55:00.000Z"
        let formattedDateString = formatDate(originalDateString)
        
        XCTAssertEqual(formattedDateString, "09:55", "expected to be equal")
    }

}
