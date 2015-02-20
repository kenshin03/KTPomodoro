//
//  KTPomodoroTaskConstants.h
//  KTPomodoro
//
//  Created by Kenny Tang on 1/8/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface KTPomodoroTaskConstants : NSObject

typedef NS_ENUM (NSUInteger, KTPomodoroActivityStatus) {
    KTPomodoroActivityStatusInProgress = 0,
    KTPomodoroActivityStatusStopped,
    KTPomodoroActivityStatusCompleted,
    KTPomodoroActivityStatusUnknown
};

typedef NS_ENUM (NSUInteger, KTPomodoroStartActivityError) {
    KTPomodoroStartActivityOtherActivityActiveError = 0,
};


@end
