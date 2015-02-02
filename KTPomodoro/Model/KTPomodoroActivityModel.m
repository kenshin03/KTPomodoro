//
//  KTPomodoroTask.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/5/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTPomodoroActivityModel.h"

// should be 25
static NSUInteger kKTPomodoroActivityModelDurationMinutes = 1;


@implementation KTPomodoroActivityModel

@dynamic activityID;
@dynamic actual_pomo;
@dynamic desc;
@dynamic expected_pomo;
@dynamic name;
@dynamic status;
@dynamic interruptions;
@dynamic created_time;
@dynamic current_pomo;
@dynamic current_pomo_elapsed_time;

- (NSUInteger)current_pomo_elapsed_time_int
{
    return [self.current_pomo_elapsed_time integerValue];
}

- (NSUInteger)current_pomo_elapsed_time_minutes_int
{
    NSInteger pomodoroSecs = kKTPomodoroActivityModelDurationMinutes*60 - [self current_pomo_elapsed_time_int];

    NSUInteger displayMinutes = (NSUInteger)floor(pomodoroSecs/60.0f);

    return displayMinutes;
}

- (NSUInteger)current_pomo_elapsed_time_seconds_int
{
    NSInteger pomodoroSecs = kKTPomodoroActivityModelDurationMinutes*60 - [self current_pomo_elapsed_time_int];

    NSUInteger displaySecs = (NSUInteger)pomodoroSecs%60;
    return displaySecs;
}

@end
