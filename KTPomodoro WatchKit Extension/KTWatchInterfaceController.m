//
//  InterfaceController.m
//  KTPomodoro WatchKit Extension
//
//  Created by Kenny Tang on 1/1/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTWatchInterfaceController.h"
#import "KTActiveTimer.h"
#import "KTCoreDataStack.h"
#import "KTPomodoroTask.h"
#import "KTPomodoroTaskConstants.h"

@interface KTWatchInterfaceController()<KTActiveTimerDelegate>

@property (nonatomic) KTPomodoroTask *task;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *plannedPomoLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *actualPomoLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *interruptionsLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;


@end

@implementation KTWatchInterfaceController



- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    if (!context) {
    }
    KTPomodoroTask *task = (KTPomodoroTask*)context;
    self.task = task;

    [self.taskNameLabel setText:task.name];
    [self.descriptionLabel setText:task.desc];
    [self.plannedPomoLabel setText:[task.expected_pomo stringValue]];
    [self.actualPomoLabel setText:[task.actual_pomo stringValue]];
    [self.interruptionsLabel setText:[self.task.interruptions stringValue]];

    [self addMenuItemWithItemIcon:WKMenuItemIconPlay title:@"Start" action:@selector(startTask:)];
    [self addMenuItemWithItemIcon:WKMenuItemIconTrash title:@"Delete" action:@selector(deleteTask:)];

//    [self addMenuItemWithItemIcon:WKMenuItemIconShare title:@"Open App" action:@selector(openApp:)];

}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];


}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [[KTCoreDataStack sharedInstance] saveContext];

}

#pragma mark - Private

- (void)interruptTask:(id)sender
{
    [self stopTask:sender];

    // increment interrupt
    NSInteger interruptions = [self.task.interruptions integerValue];
    self.task.interruptions = @(++interruptions);

    [self.interruptionsLabel setText:[NSString stringWithFormat:@"%li", (long)interruptions]];
}

- (void)startTask:(id)sender
{
    [KTActiveTimer sharedInstance].task = self.task;
    [KTActiveTimer sharedInstance].delegate = self;
    [[KTActiveTimer sharedInstance] start];
    [self.timeLabel setText:[NSString stringWithFormat:@"%@:00", @([KTActiveTimer pomodoroDurationMinutes])]];

    [self clearAllMenuItems];
    [self addMenuItemWithItemIcon:WKMenuItemIconBlock title:@"Interrupt" action:@selector(interruptTask:)];
    [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:@"Stop" action:@selector(stopTask:)];
}

- (void)stopTask:(id)sender
{
    [[KTActiveTimer sharedInstance] invalidate];
    [self taskCompleted];
}

- (void)taskCompleted
{
    [self clearAllMenuItems];
    [self addMenuItemWithItemIcon:WKMenuItemIconPlay title:@"Start" action:@selector(startTask:)];
    [self addMenuItemWithItemIcon:WKMenuItemIconTrash title:@"Delete" action:@selector(deleteTask:)];
    [self.timeLabel setText:@"00:00"];

}

- (void)deleteTask:(id)sender
{
    [self.timeLabel setText:@"00:00"];
    [[KTActiveTimer sharedInstance] invalidate];
    [[[KTCoreDataStack sharedInstance] managedObjectContext] deleteObject:self.task];
    [[KTCoreDataStack sharedInstance] saveContext];
    [self popController];
}

- (void)openApp:(id)sender
{
//    NSDictionary *userInfo = @{@"taskID" : self.task.name};
//    [WKInterfaceController openParentApplication:userInfo reply:^(NSDictionary *replyInfo, NSError *error) {
//        NSLog(@"error: %@", error);
//    }];


    [self presentTextInputControllerWithSuggestions:nil allowedInputMode:WKTextInputModePlain completion:^(NSArray *results) {
        NSLog(@"results: %@", results);
    }];
}


#pragma mark - KTActiveTimerDelegate

- (void)timerDidFire:(KTPomodoroTask*)task totalElapsedSecs:(NSUInteger)secs minutes:(NSUInteger)displayMinutes seconds:(NSUInteger)displaySecs
{
    NSString *displayMinutesString = (displayMinutes>9)?[@(displayMinutes) stringValue ]:[NSString stringWithFormat:@"0%@", @(displayMinutes)];
    NSString *displaySecsString = (displaySecs>9)?[@(displaySecs) stringValue ]:[NSString stringWithFormat:@"0%@", @(displaySecs)];

    NSString *remainingTimeString = [NSString stringWithFormat:@"%@:%@", displayMinutesString, displaySecsString];

    [self.timeLabel setText:remainingTimeString];
    [self.actualPomoLabel setText:[task.actual_pomo stringValue]];

    if ([task.status integerValue] == KTPomodoroTaskStatusCompleted) {
        [self taskCompleted];
    }
}

@end



