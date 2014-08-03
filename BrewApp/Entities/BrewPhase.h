//
//  BrewPhase.h
//  BrewApp
//
//  Created by Ágnes Vásárhelyi on 02/08/14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    INACTIVE = 0,
    ACTIVE,
    HEATING,
    FINISHED
} PhaseState;

@interface BrewPhase : NSObject

@property (nonatomic, strong) NSString *jobEnd;
@property (nonatomic, strong) NSNumber *min;
@property (nonatomic, strong) NSNumber *temp;
@property (nonatomic) BOOL inProgress;
@property (nonatomic) BOOL tempReached;
@property (nonatomic) PhaseState state;

- (UIColor *)colorForCurrentState;

@end

