//
//  PhaseCell.h
//  BrewApp
//
//  Created by Ágnes Vásárhelyi on 02/08/14.
//
//

#import <Foundation/Foundation.h>

@interface PhaseCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *minLabel;
@property (nonatomic, weak) IBOutlet UILabel *minTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *tempLabel;
@property (nonatomic, weak) IBOutlet UILabel *tempTextLabel;

@end
