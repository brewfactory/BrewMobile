//
//  ContentParser.m
//  BrewApp
//
//  Created by Ágnes Vásárhelyi on 02/08/14.
//
//

#import "ContentParser.h"

@implementation ContentParser

#pragma mark - Instance init

static ContentParser *SharedInstance;

+ (instancetype)sharedInstance
{
	return SharedInstance;
}

+ (void)initialize
{
    SharedInstance = [[ContentParser alloc] init];
}

#pragma mark - Parser methods

- (BrewState *)parseBrewStateFromRawData:(id)rawBrewState
{
    BrewState *brewState = [[BrewState alloc] init];
    
    //Needed for casting to primitive types
    NSNumber *inProgress = rawBrewState[@"inProgress"];
    NSNumber *paused = rawBrewState[@"paused"];

    brewState.inProgress = inProgress.boolValue;
    brewState.name = rawBrewState[@"name"];
    brewState.paused = paused.boolValue;
    
    NSString *startTimeString = rawBrewState[@"startTime"];
    brewState.startTime = ![startTimeString isKindOfClass:[NSNull class]] ? [self reformatDateString:startTimeString] : @"";

    [self parseBrewPhasesOfState:brewState fromRawData:rawBrewState[@"phases"]];
    
    return brewState;
}

- (void)parseBrewPhasesOfState:(BrewState *)state fromRawData:(NSArray *)rawBrewPhases
{
    NSMutableArray *phasesArray = [NSMutableArray arrayWithCapacity:rawBrewPhases.count];
    
    for (NSDictionary *rawPhase in rawBrewPhases) {
        BrewPhase *brewPhase = [[BrewPhase alloc] init];
        
        //Needed for casting to primitive types
        NSNumber *inProgress = rawPhase[@"inProgress"];
        NSNumber *tempReached = rawPhase[@"tempReached"];

        brewPhase.inProgress = inProgress.boolValue;
        brewPhase.tempReached = tempReached.boolValue;
        brewPhase.min = rawPhase[@"min"];
        brewPhase.temp = rawPhase[@"temp"];
        
        NSString *endTimeString = rawPhase[@"jobEnd"];
        brewPhase.jobEnd =  ![endTimeString isKindOfClass:[NSNull class]] ? [self reformatDateString:endTimeString] : @"";
        
        [phasesArray addObject:brewPhase];
    }
    
    state.phases = phasesArray;
}

- (NSString *)reformatDateString:(NSString *)rawDateString
{
    NSString *timeString;
    ISO8601DateFormatter *isoDateFormatter = [[ISO8601DateFormatter alloc] init];
    NSDate *formattedDate = [isoDateFormatter dateFromString:rawDateString];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH':'mm"];
    timeString = [dateFormatter stringFromDate:formattedDate];
    
    return timeString;
}

@end
