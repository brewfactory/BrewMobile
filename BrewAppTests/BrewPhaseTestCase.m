//
//  BrewPhaseTestCase.m
//  BrewApp
//
//  Created by Ágnes Vásárhelyi on 03/08/14.
//
//

#import <XCTest/XCTest.h>
#import "Specta.h"

#define EXP_SHORTHAND
#import "Expecta.h"
#import "BrewPhase.h"

SpecBegin(BrewPhase)

describe(@"BrewPhase", ^{
    __block BrewPhase *brewPhase;
    
    beforeEach(^{
        brewPhase = [[BrewPhase alloc] init];
        brewPhase.jobEnd = @"13:33";
        brewPhase.min = @3;
        brewPhase.temp = @23;
        brewPhase.inProgress = YES;
        brewPhase.tempReached = NO;
        brewPhase.state = HEATING;
    });
    
    it(@"can be created", ^{
        expect(brewPhase).toNot.beNil();
    });
    
    it(@"has a jobEnd property", ^{
        expect(brewPhase.jobEnd).to.equal(@"13:33");
    });
    
    it(@"has a min property", ^{
        expect(brewPhase.min).to.equal(@3);
    });
    
    it(@"has a temp property", ^{
        expect(brewPhase.temp).to.equal(@23);
    });
    
    it(@"has a inProgress property", ^{
        expect(brewPhase.inProgress).to.equal(YES);
    });
    
    it(@"has a tempReached property", ^{
        expect(brewPhase.tempReached).to.equal(NO);
    });
    
    it(@"has a state property", ^{
        expect(brewPhase.state).to.equal(HEATING);
    });
    
    afterEach(^{
        brewPhase = nil;
    });
});

SpecEnd