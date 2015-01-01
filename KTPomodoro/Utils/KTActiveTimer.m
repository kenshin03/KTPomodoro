//
//  KTActiveTimer.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/1/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTActiveTimer.h"

static NSUInteger kKTPomodoroDurationMinutes = 25;

@interface KTActiveTimer()

@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger activeTaskElapsedSecs;

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
}

- (void)start {
    if (![self.timer isValid]) {
        self.activeTaskElapsedSecs = 0;
        self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(taskTimerFired:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
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
    if (self.activeTaskElapsedSecs == kKTPomodoroDurationMinutes*60) {
        // stop the timer
        [self.timer invalidate];
        self.activeTaskElapsedSecs = 0;
        // increment actual pomo count in model
    }
    [self.delegate timerDidFire:self.task elapsedSecs:self.activeTaskElapsedSecs];
}


@end
