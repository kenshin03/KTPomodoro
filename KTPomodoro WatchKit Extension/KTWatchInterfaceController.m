//
//  InterfaceController.m
//  KTPomodoro WatchKit Extension
//
//  Created by Kenny Tang on 1/1/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTWatchInterfaceController.h"
#import "KTActivityManager.h"
#import "KTCoreDataStack.h"
#import "KTPomodoroActivityModel.h"
#import "KTPomodoroTaskConstants.h"
#import "KTSharedUserDefaults.h"

@interface KTWatchInterfaceController()<KTActivityManagerDelegate>

@property (nonatomic) KTPomodoroActivityModel *activity;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *plannedPomoLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *remainingPomoLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *timeLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *timerRingInterfaceGroup;

@property (nonatomic) NSString *currentBackgroundImageString;

@end

@implementation KTWatchInterfaceController



- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    KTPomodoroActivityModel *activity = (KTPomodoroActivityModel*)context;
    self.activity = activity;
    [self.taskNameLabel setText:activity.name];
    [self.plannedPomoLabel setText:[activity.expected_pomo stringValue]];
    self.currentBackgroundImageString = @"";
    [self.remainingPomoLabel setText:[activity.expected_pomo stringValue]];

    [self registerUserDefaultChanges];
    [self clearAllMenuItems];

    KTActivityManager *activityManager = [KTActivityManager sharedInstance];
    if (activity.status.integerValue == KTPomodoroActivityStatusInProgress){

        if ([KTActivityManager sharedInstance].activity != self.activity) {

            [[KTActivityManager sharedInstance] startActivity:activity error:nil];
        }

        // continue task
        activityManager.delegate = self;

        [self addMenuItemWithItemIcon:WKMenuItemIconBlock title:@"Interrupt" action:@selector(interruptTask:)];
        [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:@"Stop" action:@selector(stopTask:)];

    } else {

        if (![activityManager hasOtherActiveActivityInSharedState:activity.activityID]) {
            [self addMenuItemWithItemIcon:WKMenuItemIconPlay title:@"Start" action:@selector(startTask:)];
            [self addMenuItemWithItemIcon:WKMenuItemIconTrash title:@"Delete" action:@selector(deleteTask:)];
        }
    }

}


- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [self unregisterUserDefaultChanges];
    [[KTCoreDataStack sharedInstance] saveContext];

}

#pragma mark - Private

#pragma mark - awakeWithContext: helper methods

- (void)registerUserDefaultChanges
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsUpdated) name:NSUserDefaultsDidChangeNotification object:nil];
}

#pragma mark - didDeactivate helper methods

- (void)unregisterUserDefaultChanges
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

#pragma mark - registerUserDefaultChanges helper methods

- (void)userDefaultsUpdated
{
    BOOL shouldAutoComplete = [KTSharedUserDefaults shouldAutoDeleteCompletedActivites];
    NSUInteger breakDuration = [KTSharedUserDefaults breakDuration];
    NSUInteger pomoDuration = [KTSharedUserDefaults pomoDuration];
    NSLog(@"shouldAutoComplete: %i", shouldAutoComplete);
    NSLog(@"breakDuration: %@", @(breakDuration));
    NSLog(@"pomoDuration: %@", @(pomoDuration));
}


#pragma mark - Action Outlets

- (void)interruptTask:(id)sender
{
    [self stopTask:sender];

    // increment interrupt
    NSInteger interruptions = [self.activity.interruptions integerValue];
    self.activity.interruptions = @(++interruptions);

}

- (void)startTask:(id)sender
{
    NSError *startTaskError;
    KTActivityManager *activityManager = [KTActivityManager sharedInstance];
    activityManager.delegate = self;
    [activityManager startActivity:self.activity error:&startTaskError];

    if (!startTaskError) {
        [self.timeLabel setText:[NSString stringWithFormat:@"%@:00", @([KTActivityManager pomodoroDurationMinutes])]];

        [self clearAllMenuItems];
        [self addMenuItemWithItemIcon:WKMenuItemIconBlock title:@"Interrupt" action:@selector(interruptTask:)];
        [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:@"Stop" action:@selector(stopTask:)];
    }
}

- (void)stopTask:(id)sender
{
    [[KTActivityManager sharedInstance] stopActivity];
    [self resetMenuItemsTimeLabel];
    [self resetBackgroundImage];
}

- (void)taskCompleted
{
    [self resetMenuItemsTimeLabel];

    if ([self shouldAutoDeleteCompletedTasks]) {
        [self deleteTask:nil];
    }

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

#pragma mark - taskCompleted helper methods

- (void)resetBackgroundImage
{
    [self.timerRingInterfaceGroup setBackgroundImageNamed:@"circles_background"];
}

- (void)resetMenuItemsTimeLabel
{
    [self clearAllMenuItems];
    [self addMenuItemWithItemIcon:WKMenuItemIconPlay title:@"Start" action:@selector(startTask:)];
    [self addMenuItemWithItemIcon:WKMenuItemIconTrash title:@"Delete" action:@selector(deleteTask:)];
    [self.timeLabel setText:@"00:00"];

}

- (BOOL)shouldAutoDeleteCompletedTasks
{
    return [KTSharedUserDefaults shouldAutoDeleteCompletedActivites];
}


#pragma mark - KTActivityManagerDelegate methods

- (void)activityManager:(KTActivityManager *)manager activityPausedForBreak:(NSUInteger)elapsedTime
{

}

- (void)activityManager:(KTActivityManager *)manager activityDidUpdate:(KTPomodoroActivityModel *)activity
{

    [self updateTimerBackgroundImage:activity];


    NSString *displayMinutesString = [self formatTimeIntToTwoDigitsString:[KTActivityManager  pomoRemainingMinutes:activity.current_pomo_elapsed_time_int]];

    NSString *displaySecsString = [self formatTimeIntToTwoDigitsString:[KTActivityManager  pomoRemainingSecsInCurrentMinute:activity.current_pomo_elapsed_time_int]];

    NSString *remainingTimeString = [NSString stringWithFormat:@"%@:%@", displayMinutesString, displaySecsString];

    [self.timeLabel setText:remainingTimeString];

    NSUInteger remainingPomo = [activity.expected_pomo integerValue] - [activity.actual_pomo integerValue];

    [self.remainingPomoLabel setText:[@(remainingPomo) stringValue]];

    if ([activity.status integerValue] == KTPomodoroActivityStatusCompleted) {
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

    NSString *backgroundImageString = [NSString stringWithFormat:@"circles_%@", @(elapsedSections)];
    NSLog(@"backgroundImageString: %@", backgroundImageString);
    if (![self.currentBackgroundImageString isEqualToString:backgroundImageString]) {
        self.currentBackgroundImageString = backgroundImageString;
        [self.timerRingInterfaceGroup setBackgroundImageNamed:backgroundImageString];
    }
}



@end



