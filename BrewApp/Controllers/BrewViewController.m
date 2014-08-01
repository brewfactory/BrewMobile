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

@interface BrewViewController ()
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
             NSDictionary *brewInfo = brewData;
             NSNumber *inProgress = brewInfo[@"inProgress"];
             
             if (brewInfo && inProgress.intValue == 1) {
                 NSArray *phases = brewInfo[@"phases"];
                
                 if(phases.count > 0) {
                     NSDictionary *currentPhase = phases[0];
                    [weakSelf performSelectorOnMainThread:@selector(updatePhaseLabel:) withObject:currentPhase waitUntilDone:NO];
                 }
             }
         }];
         
         //Temperature changed
         [self.socket on:EVENT_TEMPERATURE do:^(NSNumber *newTemp) {
             if (newTemp) {
                 NSLog(@"Temperature update: %.2f ˚C", newTemp.floatValue);
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

- (void)updatePhaseLabel:(NSDictionary *)currentPhase
{
    NSNumber *temp = currentPhase[@"temp"];
    NSNumber *tempReached = currentPhase[@"tempReached"];
    
    phaseLabel.text = [NSString stringWithFormat:@"Temp: %.2f ˚C,\n temp reached: %@", temp.floatValue, tempReached.intValue == 1 ? @"yes" : @"no"];
}

- (void)updateTempLabel:(NSNumber *)newTemp
{
    tempLabel.text = [NSString stringWithFormat:@"%.2f ˚C", newTemp.floatValue];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
