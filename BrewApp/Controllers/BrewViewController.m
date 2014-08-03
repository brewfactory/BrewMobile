//
//  BrewViewController.m
//  BrewApp
//
//  Created by Ágnes Vásárhelyi on 01/08/14.
//
//

#import "BrewViewController.h"

#define EVENT_BREW @"brew_changed"
#define EVENT_TEMPERATURE @"temperature_changed"
#define EVENT_PWM @"pwm_changed"

@interface BrewViewController () {
    BrewState *actBrewState;
}
@property (nonatomic, strong) SIOSocket *socket;
@property (nonatomic, strong) NSString *host;
@property (nonatomic) BOOL socketIsConnected;

@end

@implementation BrewViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.host = @"http://localhost:3000";
    [self openConnection];
}

#pragma mark - Socket.IO communication

- (void)openConnection
{
    [SIOSocket socketWithHost:self.host response: ^(SIOSocket *socket)
     {
         self.socket = socket;
         __weak typeof(self) weakSelf = self;
         
         //Connection status
         self.socket.onConnect = ^() {
             weakSelf.socketIsConnected = YES;
             NSLog(@"Connected to host %@", weakSelf.host);
         };
         
         self.socket.onDisconnect = ^() {
             NSLog(@"Disconnected from host %@", weakSelf.host);
         };
         
         //Custom events
         
         //Brew status changed
         [self.socket on:EVENT_BREW do:^(id brewData) {
            actBrewState = [[ContentParser sharedInstance] parseBrewStateFromRawData:brewData];
            [phasesTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

            [self performSelectorOnMainThread:@selector(updateNameLabel) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(updateStartTimeLabel) withObject:nil waitUntilDone:NO];
         }];
         
         //Temperature changed
         [self.socket on:EVENT_TEMPERATURE do:^(NSNumber *newTemp) {
             if (![newTemp isKindOfClass:[NSNull class]]) {
                 [weakSelf performSelectorOnMainThread:@selector(updateTempLabel:) withObject:newTemp waitUntilDone:NO];
             } else {
                 NSLog(@"No data available for temperature.");
             }
         }];
       
         //PWM changed
         /*[self.socket on:EVENT_PWM do:^(id data) {
              NSLog(@"PWM update: %@", data);
          }];*/
     }];
}

#pragma mark - Refreshing UI

- (void)updateNameLabel
{
    nameLabel.text = actBrewState.name ? [NSString stringWithFormat:@"Brewing %@ at", actBrewState.name] : @"";
}

- (void)updateTempLabel:(NSNumber *)newTemp
{
    tempLabel.text = newTemp ? [NSString stringWithFormat:@"%.2f ˚C", newTemp.floatValue] : @"";
}

- (void)updateStartTimeLabel
{
    startTimeLabel.text = actBrewState.startTime ? [NSString stringWithFormat:@"started %@", actBrewState.startTime] : @"";
}

- (UIColor *)colorForPhase:(BrewPhase *)phase
{
    UIColor *bgColor = [UIColor whiteColor];
    if (phase.inProgress && !phase.tempReached) {
        //Heating in progress
        bgColor = [UIColor colorWithRed:240.0 / 255.0 green:173.0 / 255.0 blue:78.0 / 255.0 alpha:1.0];
    } else if(phase.inProgress && phase.tempReached) {
        //Brewing still in progress
        bgColor = [UIColor colorWithRed:66.0 / 255.0 green:139.0 / 255.0 blue:202.0 / 255.0 alpha:1.0];
    } else if(!phase.inProgress && phase.tempReached) {
        //Brew ended
        bgColor = [UIColor colorWithRed:92.0 / 255.0 green:184.0 / 255.0 blue:92.0 / 255.0 alpha:1.0];
    } else if(!phase.inProgress && !phase.tempReached) {
        //Brew inactive
        bgColor = [UIColor colorWithRed:245.0 / 255.0 green:245.0 / 255.0 blue:245.0 / 255.0 alpha:1.0];
    }
    return bgColor;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return actBrewState && actBrewState.phases ? actBrewState.phases.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhaseCell";
    PhaseCell *cell = (PhaseCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (PhaseCell *)[nib objectAtIndex:0];
    }
    
    if (actBrewState && actBrewState.phases && actBrewState.phases.count > indexPath.row) {
        BrewPhase *phase = actBrewState.phases[indexPath.row];
        
        cell.minLabel.text = [NSString stringWithFormat:@"%@", phase.min];
        cell.tempLabel.text = [NSString stringWithFormat:@"%@", phase.temp];
        cell.statusLabel.text = !phase.inProgress && phase.tempReached ? [NSString stringWithFormat:@"finished at %@", phase.jobEnd] : @"";
        
        [UIView animateWithDuration:0.3f animations:^{
            cell.backgroundColor = [self colorForPhase:phase];
            if (!phase.inProgress && !phase.tempReached) {
                [cell setTextColorForAllLabels:[UIColor blackColor]];
            }
        }];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Not sure if we want to have selection
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
