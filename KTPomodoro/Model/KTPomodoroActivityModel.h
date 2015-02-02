//
//  KTPomodoroTask.h
//  KTPomodoro
//
//  Created by Kenny Tang on 1/5/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KTPomodoroActivityModel : NSManagedObject

@property (nonatomic, retain) NSString * activityID;
@property (nonatomic, retain) NSNumber * actual_pomo;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * expected_pomo;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * interruptions;
@property (nonatomic, retain) NSDate * created_time;

@property (nonatomic, retain) NSNumber * current_pomo;
@property (nonatomic, retain) NSNumber * current_pomo_elapsed_time;
@property (nonatomic, readonly) NSUInteger current_pomo_elapsed_time_int;
@property (nonatomic, readonly) NSUInteger current_pomo_elapsed_time_minutes_int;
@property (nonatomic, readonly) NSUInteger current_pomo_elapsed_time_seconds_int;

@end
