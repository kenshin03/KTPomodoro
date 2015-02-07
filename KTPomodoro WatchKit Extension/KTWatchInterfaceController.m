//
//  InterfaceController.m
//  KTPomodoro WatchKit Extension
//
//  Created by Kenny Tang on 1/1/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTWatchInterfaceController.h"
#import "KTCoreDataStack.h"
#import "KTPomodoroActivityModel.h"
#import "KTPomodoroTaskConstants.h"
#import "KTActivityManager.h"

@interface KTWatchInterfaceController()<KTActivityManagerDelegate>

@property (nonatomic) KTPomodoroActivityModel *activity;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *plannedPomoLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *remainingPomoLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *timerRingInterfaceGroup;

@property (nonatomic) NSString *currentBackgroundImage;

@end

@implementation KTWatchInterfaceController



- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    if (!context) {
    }
    KTPomodoroActivityModel *activity = (KTPomodoroActivityModel*)context;
    self.activity = activity;
    self.currentBackgroundImage = @"";

    [self.taskNameLabel setText:activity.name];
    [self.plannedPomoLabel setText:[activity.expected_pomo stringValue]];
    [self.remainingPomoLabel setText:[activity.expected_pomo stringValue]];

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
    NSInteger interruptions = [self.activity.interruptions integerValue];
    self.activity.interruptions = @(++interruptions);

}

- (void)startTask:(id)sender
{
//    [KTActiveActivityTimer sharedInstance].activity = self.activity;
//    [KTActiveActivityTimer sharedInstance].delegate = self;

//
    KTActivityManager *activityManager = [KTActivityManager sharedInstance];
    activityManager.delegate = self;
    [activityManager startActivity:self.activity];


    [self.timeLabel setText:[NSString stringWithFormat:@"%@:00", @([KTActivityManager pomodoroDurationMinutes])]];

    [self clearAllMenuItems];
    [self addMenuItemWithItemIcon:WKMenuItemIconBlock title:@"Interrupt" action:@selector(interruptTask:)];
    [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:@"Stop" action:@selector(stopTask:)];
}

- (void)stopTask:(id)sender
{
    [[KTActivityManager sharedInstance] stopActivity];
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
    [[KTActivityManager sharedInstance] stopActivity];
    [[[KTCoreDataStack sharedInstance] managedObjectContext] deleteObject:self.activity];
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

#pragma mark - KTActivityManagerDelegate methods

- (void)activityManager:(KTActivityManager *)manager activityPausedForBreak:(NSUInteger)elapsedTime
{

}

- (void)activityManager:(KTActivityManager *)manager activityDidUpdate:(KTPomodoroActivityModel *)activity
{

    [self updateTimerBackgroundImage:activity];


    NSString *displayMinutesString = [self formatTimeIntToTwoDigitsString:activity.current_pomo_elapsed_time_minutes_int];

    NSString *displaySecsString = [self formatTimeIntToTwoDigitsString:activity.current_pomo_elapsed_time_seconds_int];

    NSString *remainingTimeString = [NSString stringWithFormat:@"%@:%@", displayMinutesString, displaySecsString];

//    [self.taskNameLabel setText:[activity.actual_pomo stringValue]];

    [self.timeLabel setText:remainingTimeString];

    NSUInteger remainingPomo = [activity.expected_pomo integerValue] - [activity.actual_pomo integerValue];

    [self.remainingPomoLabel setText:[@(remainingPomo) stringValue]];

    if ([activity.status integerValue] == KTPomodoroTaskStatusCompleted) {
        [self.taskNameLabel setText:@"Yeah done!"];
        [self taskCompleted];
    }

}

#pragma mark - activityManager:activityDidUpdate: helper method

- (NSString*)formatTimeIntToTwoDigitsString:(NSUInteger)time
{
    NSString *displayString = (time>9)?[@(time) stringValue]:[NSString stringWithFormat:@"0%@", @(time)];
    return displayString;
}

- (void)updateTimerBackgroundImage:(KTPomodoroActivityModel *)activity
{
    NSUInteger elapsedSecs = activity.current_pomo_elapsed_time_int;
    NSUInteger elapsedSections = elapsedSecs/(([KTActivityManager pomodoroDurationMinutes]*60)/12);

    NSString *backgroundImage = [NSString stringWithFormat:@"circles_background_%@.png", @(elapsedSections)];
    if (![self.currentBackgroundImage isEqualToString:backgroundImage]) {
        self.currentBackgroundImage = backgroundImage;
        [self.timerRingInterfaceGroup setBackgroundImageNamed:backgroundImage];
    }
}


#pragma mark - KTActiveTimerDelegate
/*
- (void)timerDidFire:(KTPomodoroActivityModel*)task totalElapsedSecs:(NSUInteger)secs minutes:(NSUInteger)displayMinutes seconds:(NSUInteger)displaySecs
{
    NSString *displayMinutesString = (displayMinutes>9)?[@(displayMinutes) stringValue ]:[NSString stringWithFormat:@"0%@", @(displayMinutes)];
    NSString *displaySecsString = (displaySecs>9)?[@(displaySecs) stringValue ]:[NSString stringWithFormat:@"0%@", @(displaySecs)];

    NSString *remainingTimeString = [NSString stringWithFormat:@"%@:%@", displayMinutesString, displaySecsString];

//    [self.timeLabel setTextColor:[UIColor whiteColor]];

    if (secs%2 == 0) {
        [self.timeLabel setTextColor:[UIColor greenColor]];

    } else {
        [self.timeLabel setTextColor:[UIColor redColor]];
    }
    [self.taskNameLabel setText:[self.activity.actual_pomo stringValue]];

    [self.timeLabel setText:remainingTimeString];
    [self.actualPomoLabel setText:[task.actual_pomo stringValue]];

    if ([task.status integerValue] == KTPomodoroTaskStatusCompleted) {
        [self.taskNameLabel setText:@"Yeah done!"];
        [self taskCompleted];
    }
}

- (void)breakTimerDidFire:(KTPomodoroActivityModel *)task totalElapsedSecs:(NSUInteger)secs minutes:(NSUInteger)displayMinutes seconds:(NSUInteger)displaySecs
{
    NSString *displayMinutesString = (displayMinutes>9)?[@(displayMinutes) stringValue ]:[NSString stringWithFormat:@"0%@", @(displayMinutes)];
    NSString *displaySecsString = (displaySecs>9)?[@(displaySecs) stringValue ]:[NSString stringWithFormat:@"0%@", @(displaySecs)];

    NSString *remainingTimeString = [NSString stringWithFormat:@"%@:%@", displayMinutesString, displaySecsString];

    [self.timeLabel setTextColor:[UIColor greenColor]];

    [self.timeLabel setText:remainingTimeString];
    [self.taskNameLabel setText:@"Break"];
}
*/
@end



