//
//  KTActiveTimer.h
//  KTPomodoro
//
//  Created by Kenny Tang on 1/1/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPomodoroTask.h"


@protocol KTActiveTimerDelegate <NSObject>

- (void)timerDidFire:(KTPomodoroTask*)task totalElapsedSecs:(NSUInteger)secs minutes:(NSUInteger)min seconds:(NSUInteger)seconds;

@end

@interface KTActiveTimer : NSObject

@property (nonatomic) KTPomodoroTask *task;
@property (nonatomic, weak) id<KTActiveTimerDelegate> delegate;

+ (instancetype)sharedInstance;

+ (NSUInteger)pomodoroDurationMinutes;

- (BOOL)isValid;

- (void)invalidate;

- (void)start;

@end
