//
//  KTActiveTimer.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/1/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTActiveActivityTimer.h"
#import "KTPomodoroTaskConstants.h"

// should be 25
static NSUInteger kKTPomodoroDurationMinutes = 1;
// should be 5
static NSUInteger kKTPomodoroBreakMinutes = 1;

@interface KTActiveActivityTimer()

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer *breakTimer;
@property (atomic) NSInteger activePomoElapsedSecs;
@property (atomic) NSInteger taskElapsedSecs;

@property (atomic) NSInteger breakElapsedSecs;

@end

@implementation KTActiveActivityTimer

#pragma mark - Public

+ (instancetype)sharedInstance {
    static KTActiveActivityTimer *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [KTActiveActivityTimer new];
    });
    return _instance;
}

+ (NSUInteger)pomodoroDurationMinutes {
    return kKTPomodoroDurationMinutes;
}

+ (NSUInteger)breakMinutes {
    return kKTPomodoroBreakMinutes;
}

- (BOOL)isValid {
    return [self.timer isValid];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;

    self.task.status = @(KTPomodoroTaskStatusStopped);

    // reset the clock
    self.activePomoElapsedSecs = 0.0f;
    self.taskElapsedSecs = 0.0f;
    [self taskTimerFired:nil];
}

- (void)start {
    if (![self.timer isValid]) {
        self.activePomoElapsedSecs = 0;
        self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(taskTimerFired:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        self.task.status = @(KTPomodoroTaskStatusInProgress);
    } else {
        self.activePomoElapsedSecs = 0;
        self.taskElapsedSecs = 0.0f;
        [self stopTimer];
    }
}

- (void)startBreak {
    if (![self.breakTimer isValid]) {
        self.breakElapsedSecs = 0;
        self.breakTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(breakTimerFired:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.breakTimer forMode:NSDefaultRunLoopMode];

    } else {
        self.breakElapsedSecs = 0;
        [self.breakTimer invalidate];
        self.breakTimer = nil;
    }
}

- (void)stopBreak {
    [self.breakTimer invalidate];
    self.breakTimer = nil;
    self.breakElapsedSecs = 0.0f;
}

#pragma mark - Private

#pragma mark - start helper method

- (void)taskTimerFired:(id)sender
{
    KTPomodoroTask *task = self.task;

    self.taskElapsedSecs++;
    self.activePomoElapsedSecs++;
    if (self.activePomoElapsedSecs == kKTPomodoroDurationMinutes*60) {

        // stop the current pomo timer
        [self.timer invalidate];
        self.activePomoElapsedSecs = 0;

        // increment actual pomo count in model
        NSUInteger actualPomo = task.actual_pomo? [task.actual_pomo integerValue] :1;
        task.actual_pomo = @(++actualPomo);

        // if pomo count == expected pomo, done
        if ([self.task.expected_pomo integerValue] == actualPomo) {
            self.taskElapsedSecs = 0;
            task.status = @(KTPomodoroTaskStatusCompleted);


            NSInteger pomodoroSecs = [KTActiveActivityTimer pomodoroDurationMinutes]*60 - self.activePomoElapsedSecs;

            NSUInteger displayMinutes = (NSUInteger)floor(pomodoroSecs/60.0f);
            NSUInteger displaySecs = (NSUInteger)pomodoroSecs%60;
            [self.delegate timerDidFire:self.task totalElapsedSecs:self.activePomoElapsedSecs minutes:displayMinutes seconds:displaySecs];

        } else if([task.expected_pomo integerValue] > actualPomo){
            // start the break timer
            [self startBreak];

        }
    } else {

        NSInteger pomodoroSecs = [KTActiveActivityTimer pomodoroDurationMinutes]*60 - self.activePomoElapsedSecs;

        NSUInteger displayMinutes = (NSUInteger)floor(pomodoroSecs/60.0f);
        NSUInteger displaySecs = (NSUInteger)pomodoroSecs%60;

        [self.delegate timerDidFire:self.task totalElapsedSecs:self.activePomoElapsedSecs minutes:displayMinutes seconds:displaySecs];

    }

}

#pragma mark - break helper method

- (void)breakTimerFired:(id)sender
{
    self.breakElapsedSecs++;
    if (self.breakElapsedSecs > kKTPomodoroBreakMinutes*60) {
        // stop the timer
        [self stopBreak];
        [self start];


        // proceed with next pomodoro
    } else {
        NSInteger breakSecs = [KTActiveActivityTimer breakMinutes]*60 - self.breakElapsedSecs;

        NSUInteger displayMinutes = (NSUInteger)floor(breakSecs/60.0f);
        NSUInteger displaySecs = (NSUInteger)breakSecs%60;

        [self.delegate breakTimerDidFire:self.task totalElapsedSecs:self.breakElapsedSecs minutes:displayMinutes seconds:displaySecs];

    }

}


@end
