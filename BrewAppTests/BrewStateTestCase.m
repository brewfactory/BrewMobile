//
//  BrewStateTestCase.m
//  BrewApp
//
//  Created by Ágnes Vásárhelyi on 03/08/14.
//
//

#import <XCTest/XCTest.h>
#import "Specta.h"

#define EXP_SHORTHAND
#import "Expecta.h"
#import "BrewState.h"
#import "BrewPhase.h"

SpecBegin(BrewState)

describe(@"BrewState", ^{
    __block BrewState *brewState;
    __block BrewPhase *brewPhase = [[BrewPhase alloc] init];
    
    beforeEach(^{
        brewState = [[BrewState alloc] init];
        brewState.startTime = @"11:23";
        brewState.name = @"Very IPA";
        brewState.phases = [NSArray arrayWithObjects:brewPhase, nil];
        brewState.paused = NO;
        brewState.inProgress = YES;
    });
    
    it(@"can be created", ^{
        expect(brewState).toNot.beNil();
    });
    
    it(@"has a startTime property", ^{
        expect(brewState.startTime).to.equal(@"11:23");
    });
    
    it(@"has a name property", ^{
        expect(brewState.name).to.equal(@"Very IPA");
    });
    
    it(@"has a phases property", ^{
        expect(brewState.phases).to.equal([NSArray arrayWithObjects:brewPhase, nil]);
    });
    
    it(@"has a inProgress property", ^{
        expect(brewState.inProgress).to.equal(YES);
    });
    
    it(@"has a paused property", ^{
        expect(brewState.paused).to.equal(NO);
    });
    
    afterEach(^{
        brewState = nil;
    });
});

SpecEnd