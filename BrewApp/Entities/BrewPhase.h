//
//  BrewPhase.h
//  BrewApp
//
//  Created by Ágnes Vásárhelyi on 02/08/14.
//
//

#import <Foundation/Foundation.h>

@interface BrewPhase : NSObject

@property (nonatomic, strong) NSString *jobEnd;
@property (nonatomic, strong) NSNumber *min;
@property (nonatomic, strong) NSNumber *temp;
@property (nonatomic) BOOL inProgress;
@property (nonatomic) BOOL tempReached;

@end
