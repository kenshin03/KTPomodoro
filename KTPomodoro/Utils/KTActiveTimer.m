//
//  KTActiveTimer.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/1/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTActiveTimer.h"
#import "KTPomodoroTaskConstants.h"

static NSUInteger kKTPomodoroDurationMinutes = 2;

@interface KTActiveTimer()

@property (nonatomic) NSTimer *timer;
@property (atomic) NSInteger activeTaskElapsedSecs;

@end

@implementation KTActiveTimer

#pragma mark - Public

+ (instancetype)sharedInstance {
    static KTActiveTimer *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [KTActiveTimer new];
    });
    return _instance;
}

+ (NSUInteger)pomodoroDurationMinutes {
    return kKTPomodoroDurationMinutes;
}

- (BOOL)isValid {
    return [self.timer isValid];
}

- (void)invalidate {
    [self.timer invalidate];
    self.timer = nil;

    self.task.status = @(KTPomodoroTaskStatusStopped);

    // reset the clock
    self.activeTaskElapsedSecs = 0.0f;
    [self taskTimerFired:nil];
}

- (void)start {
    if (![self.timer isValid]) {
        self.activeTaskElapsedSecs = 0;
        self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(taskTimerFired:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        self.task.status = @(KTPomodoroTaskStatusInProgress);
    } else {
        self.activeTaskElapsedSecs = 0;
        [self invalidate];
    }

}

#pragma mark - Private

#pragma mark - start helper method

- (void)taskTimerFired:(id)sender
{
    self.activeTaskElapsedSecs++;
    if (self.activeTaskElapsedSecs > kKTPomodoroDurationMinutes*60) {
        // stop the timer
        [self.timer invalidate];
        self.activeTaskElapsedSecs = 0;
        // increment actual pomo count in model
        NSUInteger actualPomo = self.task.actual_pomo? [self.task.actual_pomo integerValue] :1;
        self.task.actual_pomo = @(++actualPomo);
        self.task.status = @(KTPomodoroTaskStatusCompleted);

    }

    NSInteger pomodoroSecs = [KTActiveTimer pomodoroDurationMinutes]*60 - self.activeTaskElapsedSecs;

    NSUInteger displayMinutes = (NSUInteger)floor(pomodoroSecs/60.0f);
    NSUInteger displaySecs = (NSUInteger)pomodoroSecs%60;

    [self.delegate timerDidFire:self.task totalElapsedSecs:self.activeTaskElapsedSecs minutes:displayMinutes seconds:displaySecs];
}


@end
