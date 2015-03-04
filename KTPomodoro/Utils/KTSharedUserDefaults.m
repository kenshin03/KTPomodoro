//
//  KTSharedUserDefaults.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/22/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTSharedUserDefaults.h"

// This turns storing UserDefaults storing in app container on and off.
#define kKTSharedUserDefaultsShouldUseAppContainer 0


static NSString *kKTSharedUserDefaultsShouldAutoDeleteCompletedActivities = @"delete_completed_activities";
static NSString *kKTSharedUserDefaultsPomoDuration = @"pomo_length";
static NSString *kKTSharedUserDefaultsBreakDuration = @"break_length";

@implementation KTSharedUserDefaults

+ (NSUserDefaults*)sharedUserDefaults
{
    static NSUserDefaults *sharedDefaults;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifdef kKTSharedUserDefaultsShouldUseAppContainer
        sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.corgitoergosum.KTPomodoro"];
#else
        sharedDefaults = [NSUserDefaults standardUserDefaults];
#endif
    });
    return sharedDefaults;
}

+ (NSUInteger)pomoDuration
{
    return ([[KTSharedUserDefaults sharedUserDefaults] integerForKey:kKTSharedUserDefaultsPomoDuration]>0?[[KTSharedUserDefaults sharedUserDefaults] integerForKey:kKTSharedUserDefaultsPomoDuration]:25);

}

+ (NSUInteger)breakDuration
{
    return ([[KTSharedUserDefaults sharedUserDefaults] integerForKey:kKTSharedUserDefaultsBreakDuration]>0?[[KTSharedUserDefaults sharedUserDefaults] integerForKey:kKTSharedUserDefaultsBreakDuration]:5);
}


+ (BOOL)shouldAutoDeleteCompletedActivites
{
    return ([[KTSharedUserDefaults sharedUserDefaults] boolForKey:kKTSharedUserDefaultsShouldAutoDeleteCompletedActivities]?[[KTSharedUserDefaults sharedUserDefaults] boolForKey:kKTSharedUserDefaultsShouldAutoDeleteCompletedActivities]:YES);
}

@end
