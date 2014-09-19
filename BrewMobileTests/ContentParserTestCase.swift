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

    override func setUp() {
        super.setUp()
        
        NSTimeZone.setDefaultTimeZone(NSTimeZone(forSecondsFromGMT: +0))
    }
    
    override func tearDown() {
        NSTimeZone.setDefaultTimeZone(NSTimeZone.defaultTimeZone())

        super.tearDown()
    }

    func testFormatDate() {
        let originalDateString = "2014-08-03T09:55:00.000Z"
        let formattedDateString = formatDate(originalDateString)
        
        XCTAssertEqual(formattedDateString, "09:55", "expected to be equal")
    }

}
