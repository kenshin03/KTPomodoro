//
//  KTPomodoroTask.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/5/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTPomodoroActivityModel.h"

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
@end
