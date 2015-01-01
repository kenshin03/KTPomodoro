//
//  Pomodoro.h
//  KTPomodoro
//
//  Created by Kenny Tang on 12/31/14.
//  Copyright (c) 2014 Kenny Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KTPomodoroTask : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * expected_pomo;
@property (nonatomic, retain) NSNumber * actual_pomo;

@end
