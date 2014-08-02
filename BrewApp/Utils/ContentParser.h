//
//  ContentParser.h
//  BrewApp
//
//  Created by Ágnes Vásárhelyi on 02/08/14.
//
//

#import <Foundation/Foundation.h>
#import "BrewState.h"
#import "BrewPhase.h"

@interface ContentParser : NSObject

/*!
 @method Instance
 @abstract Class getter of the Singleton instance.
 */
+ (instancetype)sharedInstance;

/*!
 @method parseBrewStateFromRawData:
 @abstract Method used to parse incoming data to entities.
 */
- (BrewState *)parseBrewStateFromRawData:(id)rawBrewState;

@end
