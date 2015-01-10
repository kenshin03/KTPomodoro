//
//  KTPomodoroTask.h
//  KTPomodoro
//
//  Created by Kenny Tang on 1/5/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KTPomodoroTask : NSManagedObject

@property (nonatomic, retain) NSNumber * actual_pomo;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * expected_pomo;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * interruptions;
@property (nonatomic, retain) NSDate * created_time;

@end
