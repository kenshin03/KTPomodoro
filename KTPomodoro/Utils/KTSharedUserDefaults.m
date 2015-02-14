//
//  KTSharedUserDefaults.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/22/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTSharedUserDefaults.h"

static NSString *kKTSharedUserDefaultsShouldAutoDeleteCompletedActivities = @"delete_completed_activities";
static NSString *kKTSharedUserDefaultsPomoDuration = @"pomo_length";
static NSString *kKTSharedUserDefaultsBreakDuration = @"break_length";

@implementation KTSharedUserDefaults

+ (NSUserDefaults*)sharedUserDefaults
{
    static NSUserDefaults *sharedDefaults;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.corgitoergosum.KTPomodoro"];
        [sharedDefaults registerDefaults:@{
                                           kKTSharedUserDefaultsShouldAutoDeleteCompletedActivities:@(YES),
                                           kKTSharedUserDefaultsBreakDuration:@(5),
                                           kKTSharedUserDefaultsPomoDuration:@(25),
                                           }];
    });
    return sharedDefaults;
}

+ (NSUInteger)pomoDuration
{
    return [[KTSharedUserDefaults sharedUserDefaults] integerForKey:kKTSharedUserDefaultsPomoDuration];

}

+ (NSUInteger)breakDuration
{
    return [[KTSharedUserDefaults sharedUserDefaults] integerForKey:kKTSharedUserDefaultsBreakDuration];
}


+ (BOOL)shouldAutoDeleteCompletedActivites
{
    return [[KTSharedUserDefaults sharedUserDefaults] boolForKey:kKTSharedUserDefaultsShouldAutoDeleteCompletedActivities];
}

@end
