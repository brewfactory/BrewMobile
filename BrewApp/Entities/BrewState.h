//
//  BrewState.h
//  BrewApp
//
//  Created by Ágnes Vásárhelyi on 02/08/14.
//
//

#import <Foundation/Foundation.h>

@interface BrewState : NSObject

@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *phases;
@property (nonatomic) BOOL paused;
@property (nonatomic) BOOL inProgress;

@end
