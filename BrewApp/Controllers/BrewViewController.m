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
    NSNumber *actTemp;
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

    self.host = @"http://brewcore-demo.herokuapp.com";
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
         [self.socket on:EVENT_BREW callback:^(NSArray *args) {
             id brewData = args.count > 0 ? args[0] : nil;
             if (brewData) {
                 actBrewState = [[ContentParser sharedInstance] parseBrewStateFromRawData:brewData];
                 [phasesTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                 
                 [self performSelectorOnMainThread:@selector(updateNameLabel) withObject:nil waitUntilDone:NO];
                 [self performSelectorOnMainThread:@selector(updateStartTimeLabel) withObject:nil waitUntilDone:NO];
             }
         }];
         
         //Temperature changed
         [self.socket on:EVENT_TEMPERATURE callback:^(NSArray *args) {
             NSNumber *newTemp = args.count > 0 ? args[0] : nil;
             if (newTemp && ![newTemp isKindOfClass:[NSNull class]]) {
                 actTemp = newTemp;
                 [weakSelf performSelectorOnMainThread:@selector(updateTempLabel) withObject:nil waitUntilDone:NO];
             } else {
                 actTemp = nil;
                 NSLog(@"No data available for temperature.");
             }
         }];
       
         //PWM changed
         /*[self.socket on:EVENT_PWM callback:^(id data) {
              NSLog(@"PWM update: %@", data);
          }];*/
     }];
}

#pragma mark - Refreshing UI

- (void)updateNameLabel
{
    nameLabel.text = actBrewState.name ? [NSString stringWithFormat:@"Brewing %@ at", actBrewState.name] : @"";
}

- (void)updateTempLabel
{
    if(actTemp) {
        tempLabel.text = actTemp ? [NSString stringWithFormat:@"%.2f ˚C", actTemp.floatValue] : @"";
    }
}

- (void)updateStartTimeLabel
{
    startTimeLabel.text = actBrewState.startTime ? [NSString stringWithFormat:@"started %@", actBrewState.startTime] : @"";
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
        if (phase.state == FINISHED) {
           cell.statusLabel.text = [NSString stringWithFormat:@"finished at %@", phase.jobEnd];
        } else if (phase.state == HEATING) {
            if(actTemp) {
                cell.statusLabel.text = [NSString stringWithFormat:@"%@", phase.temp.floatValue > actTemp.floatValue ? @"heating" : @"cooling"];
            }
        } else if (phase.state == ACTIVE) {
            cell.statusLabel.text = @"active";
        }
        
        [UIView animateWithDuration:0.3f animations:^{
            cell.backgroundColor = [phase colorForCurrentState];
            if (phase.state == INACTIVE) {
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
