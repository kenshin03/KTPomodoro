//
//  KTActiveActivityState.h
//  KTPomodoro
//
//  Created by Kenny Tang on 1/22/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KTActiveActivityState : NSObject

@property (nonatomic) NSString *activityID;
@property (nonatomic) NSNumber *status;
@property (nonatomic) NSNumber *currentPomo;
@property (nonatomic) NSNumber *elapsedSecs;


@end
