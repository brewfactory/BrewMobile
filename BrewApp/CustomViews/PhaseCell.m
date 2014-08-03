//
//  PhaseCell.m
//  BrewApp
//
//  Created by Ágnes Vásárhelyi on 02/08/14.
//
//

#import "PhaseCell.h"

@implementation PhaseCell

- (void)setTextColorForAllLabels:(UIColor *)color
{
    _minLabel.textColor = _minTextLabel.textColor = _tempLabel.textColor = _tempTextLabel.textColor = color;
}

@end