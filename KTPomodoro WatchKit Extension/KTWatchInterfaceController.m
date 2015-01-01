//
//  InterfaceController.m
//  KTPomodoro WatchKit Extension
//
//  Created by Kenny Tang on 1/1/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTWatchInterfaceController.h"
#import "KTCoreDataStack.h"
#import "KTPomodoroTask.h"

@interface KTWatchInterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *plannedPomoLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *actualPomoLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *interruptionsLabel;


@end


@implementation KTWatchInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    if (!context) {
    }
    KTPomodoroTask *task = (KTPomodoroTask*)context;
    [self.taskNameLabel setText:task.name];
    [self.descriptionLabel setText:task.desc];
    [self.plannedPomoLabel setText:[task.expected_pomo stringValue]];
    [self.actualPomoLabel setText:[task.actual_pomo stringValue]];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];

}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


@end



