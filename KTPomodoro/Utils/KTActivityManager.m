//
//  KTActivityManager.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/22/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTActivityManager.h"
#import "KTActiveActivityState.h"
#import "KTCoreDataStack.h"
#import "KTPomodoroTaskConstants.h"
#import "KTSharedUserDefaults.h"


@interface KTActivityManager()

@property (atomic) KTPomodoroActivityModel *activity;
@property (nonatomic) NSTimer *activityTimer;
@property (nonatomic) NSTimer *breakTimer;
@property (nonatomic) NSUInteger currentPomo;

@property (nonatomic) NSUInteger breakElapsed;

@end

@implementation KTActivityManager

#pragma mark - Public

+ (instancetype)sharedInstance {
    static KTActivityManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [KTActivityManager new];
    });
    return _instance;
}

+ (NSUInteger)pomodoroDurationMinutes
{
    return [KTSharedUserDefaults pomoDuration];
}

+ (NSUInteger)breakDurationMinutes
{
    return [KTSharedUserDefaults breakDuration];
}

- (void)startActivity:(KTPomodoroActivityModel*)activity error:(NSError**)error
{
    if ([self hasOtherActiveActivityInSharedState:activity.activityID]){
        // log error
        // inform delegate
        *error = [NSError errorWithDomain:@"com.corgitoergosum.net" code:KTPomodoroStartActivityOtherActivityActiveError userInfo:nil];

        return;
    }
    if (!activity) {
        return;
    }

    self.activity = activity;
    self.activity.current_pomo_elapsed_time = @(0);
    self.activity.status = @(KTPomodoroActivityStatusInProgress);
    self.currentPomo = 0;
    self.breakElapsed = 0;

    [self updateSharedActiveActivityState:activity.activityID
                              currentPomo:self.currentPomo
                                   status:activity.status];

    [self invalidateTimers];

    [self scheduleTimerInRunLoop:self.activityTimer];

}

- (void)stopActivityOnInterruption
{
    self.activity.status = @(KTPomodoroActivityStatusStopped);
    [self updateSharedActiveActivityState:self.activity.activityID
                              currentPomo:self.currentPomo
                                   status:self.activity.status];


    // save to disk
    [[KTCoreDataStack sharedInstance] saveContext];

    // house keeping
    [self resetManagerInternalState];

}

- (void)stopActivity
{
    self.activity.status = @(KTPomodoroActivityStatusStopped);
    [self updateSharedActiveActivityState:self.activity.activityID
                              currentPomo:self.currentPomo
                                   status:self.activity.status];

    // save to disk
    [[KTCoreDataStack sharedInstance] saveContext];

    // house keeping
    [self resetManagerInternalState];

}

+ (NSUInteger)pomoRemainingMinutes:(NSUInteger)totalRemainingSecs
{
    NSInteger pomodoroSecs = [KTSharedUserDefaults pomoDuration]*60 - totalRemainingSecs;

    NSUInteger displayMinutes = (NSUInteger)floor(pomodoroSecs/60.0f);

    return displayMinutes;

}

+ (NSUInteger)pomoRemainingSecsInCurrentMinute:(NSUInteger)totalRemainingSecs
{
    NSInteger pomodoroSecs = [KTSharedUserDefaults pomoDuration]*60 - totalRemainingSecs;

    NSUInteger displaySecs = (NSUInteger)pomodoroSecs%60;
    return displaySecs;
    
}

#pragma mark - Private


#pragma mark - Lazy Loading

- (NSTimer*)activityTimer
{
    if (!_activityTimer) {
        _activityTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(activityTimerFired:) userInfo:nil repeats:YES];
    }
    return _activityTimer;
}

- (NSTimer*)breakTimer
{
    if (!_breakTimer) {
        _breakTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(breakTimerFired:) userInfo:nil repeats:YES];
    }
    return _breakTimer;
}


#pragma mark - startActivity: helper methods

- (BOOL)hasOtherActiveActivityInSharedState:(NSString*)activityID
{
    id encodedActivity = [[KTSharedUserDefaults sharedUserDefaults] objectForKey:@"ActiveActivity"];
    KTActiveActivityState *activity = (KTActiveActivityState*)[NSKeyedUnarchiver unarchiveObjectWithData:encodedActivity];
    if (!activityID || !activity) {
        return NO;
    }
    return [activity.activityID isEqualToString:activityID] ? NO : YES;
}

- (void)updateSharedActiveActivityState:(NSString*)activityID currentPomo:(NSUInteger)currentPomo status:(NSNumber*)status
{
    KTActiveActivityState *activity = nil;

    id encodedActivity = [[KTSharedUserDefaults sharedUserDefaults] objectForKey:@"ActiveActivity"];
    NSObject *decodedActivity = [NSKeyedUnarchiver unarchiveObjectWithData:encodedActivity];

    activity = (KTActiveActivityState*)decodedActivity;

    if (!([activity isKindOfClass:[KTActiveActivityState class]]) ||
        !([activity.activityID isEqualToString:activityID])){
        activity = [KTActiveActivityState new];
        activity.activityID = activityID;
    }
    activity.currentPomo = @(currentPomo);
    activity.status = status;

    if (status.integerValue == KTPomodoroActivityStatusStopped) {
        [[KTSharedUserDefaults sharedUserDefaults] removeObjectForKey:@"ActiveActivity"];

    } else {
        encodedActivity = [NSKeyedArchiver archivedDataWithRootObject:activity];
        [[KTSharedUserDefaults sharedUserDefaults] setObject:encodedActivity forKey:@"ActiveActivity"];
    }
}

- (void)invalidateTimers
{
    [self.activityTimer invalidate];
    [self.breakTimer invalidate];
    _activityTimer = nil;
    _breakTimer = nil;
}

- (void)scheduleTimerInRunLoop:(NSTimer*)timer
{
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

#pragma mark - timer helper methods

- (void)activityTimerFired:(id)sender
{
    NSUInteger currentPomoElapsed = self.activity.current_pomo_elapsed_time_int+1;
    self.activity.current_pomo_elapsed_time = @(currentPomoElapsed);

    [self.delegate activityManager:self activityDidUpdate:self.activity];

    if (currentPomoElapsed == [KTActivityManager pomodoroDurationMinutes]*60) {

        // reached end of pomo, either:
        self.currentPomo++;

        if ([self activityHasMorePomo:self.activity]) {
            [self pauseActivityStartBreak];

        } else {
            // complete task if this is last pomo
            [self completeActivityOnLastPomo];
        }
    }
}

- (void)breakTimerFired:(id)sender
{
    self.breakElapsed++;
    if (self.breakElapsed < [KTActivityManager breakDurationMinutes]*60) {
        // continue break
        [self.delegate activityManager:self activityPausedForBreak:self.breakElapsed];
    } else {
        // end of break. stop break timer. clear state.
        [self invalidateTimers];
        self.breakElapsed = 0;

        // start next pomo
        [self startNextPomo];
    }
}

#pragma mark - breakTimerFired: helper methods

- (void)startNextPomo
{
    self.currentPomo++;
    self.activity.current_pomo_elapsed_time = @(0);
    [self scheduleTimerInRunLoop:self.activityTimer];

}

#pragma mark - activityTimerFired: helper methods

- (BOOL)activityHasMorePomo:(KTPomodoroActivityModel*)activity
{
    return [activity.expected_pomo integerValue]-1 > self.currentPomo;
}

- (void)completeActivityOnLastPomo
{
    self.activity.status = @(KTPomodoroActivityStatusCompleted);
    self.activity.actual_pomo = @(self.currentPomo);

    // save to disk
    [[KTCoreDataStack sharedInstance] saveContext];

    // inform delegate
    [self.delegate activityManager:self activityDidUpdate:self.activity];


    // house keeping
    [self resetManagerInternalState];

}

- (void)pauseActivityStartBreak
{
    [self stopActivityTimer];
    [self startBreakTimer];
}

#pragma mark - pauseActivityStartBreak helper method

- (void)stopActivityTimer
{
    [self.activityTimer invalidate];
    _activityTimer = nil;
}

- (void)startBreakTimer
{
    [self.breakTimer invalidate];
    _breakTimer = nil;
    [self scheduleTimerInRunLoop:self.breakTimer];
}

#pragma mark - completeActivityOnLastPomo and helper method

- (void)resetManagerInternalState
{
    // clear internal state
    _activity = nil;
    [self invalidateTimers];
    self.currentPomo = 0;
    self.breakElapsed = 0;

}








@end
