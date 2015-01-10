//
//  KTWatchInterfaceAddTaskInterfaceController.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/9/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTWatchInterfaceAddTaskInterfaceController.h"
#import "KTCoreDataStack.h"

@interface KTWatchInterfaceAddTaskInterfaceController()

@property (nonatomic) NSString *taskName;
@property (nonatomic) NSString *taskDescription;
@property (nonatomic) NSInteger expectedPomodoros;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *expectedPomodorosLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *confirmButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *taskNameButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *taskDescriptionButton;

@end


@implementation KTWatchInterfaceAddTaskInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    self.expectedPomodoros = 1;
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Action handlers

- (IBAction)enterTaskNameButtonTapped {

    [self presentTextInputControllerWithSuggestions:@[@"Secret Project", @"Exercise", @"Read", @"Work"] allowedInputMode:WKTextInputModeAllowAnimatedEmoji completion:^(NSArray *results) {
        NSLog(@"enterTaskNameButtonTapped results: %@", results);
        if ([results count]) {
            self.taskName = results[0];
            [self.taskNameButton setTitle:self.taskName];
            // default color of WKInterfaceButton unknown
            [self.taskNameButton setColor:[UIColor clearColor]];
            [self.confirmButton setColor:[UIColor darkGrayColor]];
        }
    }];
}


- (IBAction)enterDescriptionButtonTapped {
    [self presentTextInputControllerWithSuggestions:nil allowedInputMode:WKTextInputModeAllowAnimatedEmoji completion:^(NSArray *results) {
        NSLog(@"enterDescriptionButtonTapped results: %@", results);
        if ([results count]) {
            self.taskDescription = results[0];
            [self.taskDescriptionButton setTitle:self.taskDescription];
        }
    }];

}

- (IBAction)pomodorosSliderValueChanged:(float)value {
    self.expectedPomodoros = (NSUInteger)value;
    [self.expectedPomodorosLabel setText:[NSString stringWithFormat:@"%@", @(value)]];
}


- (IBAction)confirmButtonTapped {

    if (![self.taskName length]) {
        [self.taskNameButton setColor:[UIColor redColor]];
        [self.confirmButton setColor:[UIColor redColor]];
        return;
    }

    [[KTCoreDataStack sharedInstance] createNewTask:self.taskName taskDesc:self.taskDescription pomodoros:self.expectedPomodoros];

    [[KTCoreDataStack sharedInstance] saveContext];

    [self dismissController];
}

@end



