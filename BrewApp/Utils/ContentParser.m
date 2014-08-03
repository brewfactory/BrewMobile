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
    
    NSString *startTimeString = rawBrewState[@"startTime"];
    NSString *name = rawBrewState[@"name"];

    brewState.inProgress = inProgress.boolValue;
    brewState.name = ![name isKindOfClass:[NSNull class]] ? name : nil;
    brewState.paused = paused.boolValue;
    brewState.startTime = ![startTimeString isKindOfClass:[NSNull class]] ? [self reformatDateString:startTimeString] : nil;

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
        
        NSString *endTimeString = rawPhase[@"jobEnd"];

        brewPhase.inProgress = inProgress.boolValue;
        brewPhase.tempReached = tempReached.boolValue;
        brewPhase.min = rawPhase[@"min"];
        brewPhase.temp = rawPhase[@"temp"];
        brewPhase.jobEnd =  ![endTimeString isKindOfClass:[NSNull class]] ? [self reformatDateString:endTimeString] : nil;
        
        if (brewPhase.inProgress && !brewPhase.tempReached) {
            brewPhase.state = HEATING;
        } else if (brewPhase.inProgress && brewPhase.tempReached) {
            brewPhase.state = ACTIVE;
        } else if (!brewPhase.inProgress && brewPhase.tempReached) {
            brewPhase.state = FINISHED;
        } else if (!brewPhase.inProgress && !brewPhase.tempReached) {
            brewPhase.state = INACTIVE;
        }
        
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
