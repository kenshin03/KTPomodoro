//
//  KTActiveTimer.h
//  KTPomodoro
//
//  Created by Kenny Tang on 1/1/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPomodoroTask.h"


@protocol KTActiveActivityTimerDelegate <NSObject>

- (void)timerDidFire:(KTPomodoroTask*)task totalElapsedSecs:(NSUInteger)secs minutes:(NSUInteger)min seconds:(NSUInteger)seconds;

- (void)breakTimerDidFire:(KTPomodoroTask*)task totalElapsedSecs:(NSUInteger)secs minutes:(NSUInteger)min seconds:(NSUInteger)seconds;


@end

@interface KTActiveActivityTimer : NSObject

@property (nonatomic) KTPomodoroTask *task;
@property (nonatomic, weak) id<KTActiveActivityTimerDelegate> delegate;

+ (instancetype)sharedInstance;

+ (NSUInteger)pomodoroDurationMinutes;

- (BOOL)isValid;

- (void)stopTimer;

- (void)start;

@end
