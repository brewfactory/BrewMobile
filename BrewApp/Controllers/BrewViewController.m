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

             if (actBrewState.inProgress) {
                 [self performSelectorOnMainThread:@selector(updateNameLabel) withObject:nil waitUntilDone:NO];
             }
         }];
         
         //Temperature changed
         [self.socket on:EVENT_TEMPERATURE do:^(NSNumber *newTemp) {
             if (newTemp) {
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

- (void)updateTempLabel:(NSNumber *)newTemp
{
    tempLabel.text = [NSString stringWithFormat:@"%.2f ˚C", newTemp.floatValue];
}

- (void)updateNameLabel
{
    nameLabel.text = [NSString stringWithFormat:@"Brewing %@ at", actBrewState.name];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return actBrewState.phases.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhaseCell";
    PhaseCell *cell = (PhaseCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = (PhaseCell *)[nib objectAtIndex:0];
    }
    
    if (actBrewState.phases.count > indexPath.row) {
        BrewPhase *phase = actBrewState.phases[indexPath.row];
        
        cell.minLabel.text = [NSString stringWithFormat:@"%@", phase.min];
        cell.tempLabel.text = [NSString stringWithFormat:@"%@", phase.temp];
       
        [UIView animateWithDuration:0.3f animations:^{
            cell.backgroundColor = phase.tempReached ? [UIColor orangeColor] : [UIColor lightGrayColor];
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
    //not sure if we want to have selection
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
