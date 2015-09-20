//
//  ContentParserTestCase.swift
//  BrewMobile
//
//  Created by Ágnes Vásárhelyi on 19/09/14.
//  Copyright (c) 2014 Ágnes Vásárhelyi. All rights reserved.
//

import UIKit
import XCTest
import SwiftyJSON

class ContentParserTestCase: XCTestCase {
    var mockBrewState = BrewState()
    var mockBrewPhase = BrewPhase()
    let currentZone = NSTimeZone.defaultTimeZone()

    override func setUp() {
        super.setUp()
        
        NSTimeZone.setDefaultTimeZone(NSTimeZone(forSecondsFromGMT: +0))

        mockBrewPhase = BrewPhase(jobEnd: ContentParser.formatDate("2014-08-03T11:55:00.000Z"), min: 10, temp: 70, tempReached: false, inProgress: true)
        mockBrewState = BrewState(name: "Very IPA", startTime: ContentParser.formatDate("2014-08-03T09:55:00.000Z"), phases: [mockBrewPhase], paused: false, inProgress: true)
    }
    
    override func tearDown() {
        NSTimeZone.setDefaultTimeZone(currentZone)

        super.tearDown()
    }
    
    //MARK: Testing BrewState object parsing
    func testParseBrewState() {
        let brewPhaseJSON = ["jobEnd" : "2014-08-03T11:55:00.000Z", "min" : 10, "temp" : 70, "tempReached" : 0, "inProgress" : 1]
        let brewStateJSON = ["name" : "Very IPA", "startTime" : "2014-08-03T09:55:00.000Z", "phases" : [brewPhaseJSON], "paused" : false, "inProgress" : true]
        _ = ContentParser.parseBrewState(JSON(brewStateJSON))
    }
    
    func testParseBrewStateWithEmptyJSON() {
        let json = ["name" : NSNull(), "startTime" : NSNull(), "phases" : NSNull(), "paused" : NSNull(), "inProgress" : NSNull()]
        _ = ContentParser.parseBrewState(JSON(json))
    }
    
    func testParseBrewStateWithUnexpectedJSONStructure() {
        let json = ["phases" : NSNull(), "paused" : NSNull(), "inProgress" : NSNull()]
        _ = ContentParser.parseBrewState(JSON(json))
    }
    
    //MARK: Testing BrewPhase object parsing
    func testParseBrewPhase() {
        let json = ["jobEnd" : "2014-08-03T09:55:00.000Z", "min" : "100", "temp" : "76", "tempReached" : 0, "inProgress" : 1]
        _ = ContentParser.parseBrewState(JSON(json))
    }
    
    func testParseBrewPhaseWithEmptyJSON() {
        let json = ["jobEnd" : NSNull(), "min" : NSNull(), "temp" : NSNull(), "tempReached" : NSNull(), "inProgress" : NSNull()]
        _ = ContentParser.parseBrewPhase(JSON(json))
    }
    
    func testParseBrewPhaseWithUnexpectedJSONStructure() {
        let json = ["tempReached" : 0, "inProgress" : 1]
        _ = ContentParser.parseBrewPhase(JSON(json))
    }

    func testFormatDate() {
        let originalDateString = "2014-08-03T09:55:00.000Z"
        let formattedDateString = ContentParser.formatDate(originalDateString)
        
        XCTAssertEqual(formattedDateString, "09:55", "expected to be equal")
    }

}
