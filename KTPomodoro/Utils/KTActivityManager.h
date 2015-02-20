//
//  KTActivityManager.h
//  KTPomodoro
//
//  Created by Kenny Tang on 1/22/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPomodoroActivityModel.h"

@protocol KTActivityManagerDelegate;


@interface KTActivityManager : NSObject

@property (nonatomic, weak) id<KTActivityManagerDelegate> delegate;
@property (nonatomic, readonly) KTPomodoroActivityModel *activity;

+ (instancetype)sharedInstance;

+ (NSUInteger)pomodoroDurationMinutes;

+ (NSUInteger)breakDurationMinutes;

+ (NSUInteger)pomoRemainingMinutes:(NSUInteger)totalRemainingSecs;

+ (NSUInteger)pomoRemainingSecsInCurrentMinute:(NSUInteger)totalRemainingSecs;


- (void)startActivity:(KTPomodoroActivityModel*)activity error:(NSError**)error;

- (void)stopActivity;

- (void)stopActivityOnInterruption;

- (BOOL)hasOtherActiveActivityInSharedState:(NSString*)activityID;

@end


@protocol KTActivityManagerDelegate <NSObject>

- (void)activityManager:(KTActivityManager*)manager activityDidUpdate:(KTPomodoroActivityModel*)activity;

- (void)activityManager:(KTActivityManager*)manager activityPausedForBreak:(NSUInteger)elapsedTime;

@end