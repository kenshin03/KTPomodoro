//
//  KTWatchTasksRowInterfaceController.h
//  KTPomodoro
//
//  Created by Kenny Tang on 1/1/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface KTWatchTasksRowInterfaceController : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *descLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *taskStatusLabel;

@end
