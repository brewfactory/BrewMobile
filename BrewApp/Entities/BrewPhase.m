//
//  BrewPhase.m
//  BrewApp
//
//  Created by Ágnes Vásárhelyi on 02/08/14.
//
//

#import "BrewPhase.h"

@implementation BrewPhase

- (UIColor *)colorForCurrentState
{
    UIColor *bgColor = [UIColor whiteColor];
    
    switch (self.state) {
        case HEATING:
            bgColor = [UIColor colorWithRed:240.0 / 255.0 green:173.0 / 255.0 blue:78.0 / 255.0 alpha:1.0];
            break;
        case ACTIVE:
            bgColor = [UIColor colorWithRed:66.0 / 255.0 green:139.0 / 255.0 blue:202.0 / 255.0 alpha:1.0];
            break;
        case FINISHED:
            bgColor = [UIColor colorWithRed:92.0 / 255.0 green:184.0 / 255.0 blue:92.0 / 255.0 alpha:1.0];
            break;
        case INACTIVE:
            bgColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
            break;
        default:
            [UIColor whiteColor];
            break;
    }
    
    return bgColor;
}

@end
