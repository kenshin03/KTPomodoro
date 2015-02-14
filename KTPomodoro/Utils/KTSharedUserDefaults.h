//
//  KTSharedUserDefaults.h
//  KTPomodoro
//
//  Created by Kenny Tang on 1/22/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KTSharedUserDefaults : NSObject

+ (NSUserDefaults*)sharedUserDefaults;

+ (BOOL)shouldAutoDeleteCompletedActivites;

+ (NSUInteger)pomoDuration;

+ (NSUInteger)breakDuration;


@end
