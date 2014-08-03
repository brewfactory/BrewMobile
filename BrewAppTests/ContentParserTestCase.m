//
//  ContentParserTestCase.m
//  BrewApp
//
//  Created by Ágnes Vásárhelyi on 03/08/14.
//
//

#import <XCTest/XCTest.h>
#import "Specta.h"

#define EXP_SHORTHAND
#import "Expecta.h"
#import "ContentParser.h"

@interface ContentParser (Testing)

- (NSString *)reformatDateString:(NSString *)rawDateString;

@end

SpecBegin(ContentParser)

describe(@"ContentParser", ^{
    __block ContentParser *contentParser;
    
    beforeEach(^{
        contentParser = [[ContentParser alloc] init];
    });
    
    it(@"can be created", ^{
        expect(contentParser).toNot.beNil();
    });
    
    it(@"formats dates", ^{
        NSString *originalDateString = @"2014-08-03T09:55:00.000Z";
        NSString *formattedDateString = [contentParser reformatDateString:originalDateString];
        
        expect(formattedDateString).to.equal(@"11:55");
    });
    
    afterEach(^{
        contentParser = nil;
    });
});

SpecEnd