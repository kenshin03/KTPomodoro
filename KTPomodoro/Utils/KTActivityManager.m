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

// should be 25
static NSUInteger kKTPomodoroDurationMinutes = 1;
// should be 5
static NSUInteger kKTPomodoroBreakMinutes = 1;


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
    return kKTPomodoroDurationMinutes;
}

+ (NSUInteger)breakDurationMinutes
{
    return kKTPomodoroBreakMinutes;
}

- (void)startActivity:(KTPomodoroActivityModel*)activity
{
    if ([self otherActityAlreadyInSharedState]){
        // log error
        // inform delegate
        return;
    }
    if (!activity) {
        return;
    }

    self.activity = activity;
    self.activity.current_pomo_elapsed_time = @(0);
    self.activity.status = @(KTPomodoroTaskStatusInProgress);
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
    self.activity.status = @(KTPomodoroTaskStatusStopped);

    // save to disk
    [[KTCoreDataStack sharedInstance] saveContext];

    // house keeping
    [self resetManagerInternalState];

}

- (void)stopActivity
{
    self.activity.status = @(KTPomodoroTaskStatusStopped);

    // save to disk
    [[KTCoreDataStack sharedInstance] saveContext];

    // house keeping
    [self resetManagerInternalState];

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

- (BOOL)otherActityAlreadyInSharedState
{
    return NO;
    // re-enable this later
//    KTActiveActivityState *activity = [[KTSharedUserDefaults sharedUserDefaults] objectForKey:@"ActiveActivity"];
//    return activity?YES:NO;
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

    encodedActivity = [NSKeyedArchiver archivedDataWithRootObject:activity];
    [[KTSharedUserDefaults sharedUserDefaults] setObject:encodedActivity forKey:@"ActiveActivity"];
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

    if (currentPomoElapsed == kKTPomodoroDurationMinutes*60) {

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
    if (self.breakElapsed < kKTPomodoroBreakMinutes*60) {
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
    self.activity.status = @(KTPomodoroTaskStatusCompleted);
    self.activity.actual_pomo = @(self.currentPomo);

    // save to disk
    [[KTCoreDataStack sharedInstance] saveContext];

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
