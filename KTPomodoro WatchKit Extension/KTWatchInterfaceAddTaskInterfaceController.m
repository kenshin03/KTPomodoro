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
@property (nonatomic) NSInteger expectedPomodoros;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *expectedPomodorosLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *confirmButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *taskNameButton;

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

    [self presentTextInputControllerWithSuggestions:@[
                                                      @"Watch Cat videos",
                                                      @"Exercise",
                                                      @"Do some writing",
                                                      @"Read a book",
                                                      @"Work"] allowedInputMode:WKTextInputModeAllowAnimatedEmoji completion:^(NSArray *results) {
        NSLog(@"enterTaskNameButtonTapped results: %@", results);
        if ([results count]) {
            self.taskName = results[0];
            if (self.taskName.length) {
                [self.taskNameButton setTitle:self.taskName];
                [self.confirmButton setHidden:NO];
            }
        }
    }];
}

- (IBAction)pomodorosSliderValueChanged:(float)value {
    self.expectedPomodoros = (NSUInteger)floor(value);
    [self.expectedPomodorosLabel setText:[NSString stringWithFormat:@"%@", @(value)]];
}


- (IBAction)confirmButtonTapped {

    [[KTCoreDataStack sharedInstance] createNewTask:self.taskName taskDesc:@"" pomodoros:self.expectedPomodoros];

    [[KTCoreDataStack sharedInstance] saveContext];

    [self dismissController];
}

@end



