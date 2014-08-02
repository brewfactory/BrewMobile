//
//  BrewViewController.h
//  BrewApp
//
//  Created by Ágnes Vásárhelyi on 01/08/14.
//
//

#import <UIKit/UIKit.h>
#import <SIOSocket/SIOSocket.h>
#import "PhaseCell.h"

@interface BrewViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UILabel *tempLabel;
    IBOutlet UILabel *phaseLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UITableView *phasesTableView;
    
    NSArray *brewPhases;
}

@end
