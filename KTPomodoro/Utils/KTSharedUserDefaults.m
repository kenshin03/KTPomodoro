//
//  KTSharedUserDefaults.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/22/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTSharedUserDefaults.h"

@implementation KTSharedUserDefaults

+ (NSUserDefaults*)sharedUserDefaults
{
    static NSUserDefaults *sharedDefaults;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.corgitoergosum.KTPomodoro"];
    });
    return sharedDefaults;
}

@end
