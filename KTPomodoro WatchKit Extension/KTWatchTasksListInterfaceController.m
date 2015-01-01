//
//  KTWatchTasksListInterfaceController.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/1/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTWatchTasksListInterfaceController.h"
#import "KTCoreDataStack.h"
#import "KTPomodoroTask.h"
#import "KTWatchTasksRowInterfaceController.h"


@interface KTWatchTasksListInterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;


@end


@implementation KTWatchTasksListInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];

    [self setUpTable];



}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - willActivate helper method

- (void)setUpTable
{
    NSArray *tasks = [[KTCoreDataStack sharedInstance] allTasks];
    [self.table setNumberOfRows:[tasks count] withRowType:@"KTWatchTasksRowInterfaceController"];
    [tasks enumerateObjectsUsingBlock:^(KTPomodoroTask *task, NSUInteger idx, BOOL *stop) {
        KTWatchTasksRowInterfaceController *row = (KTWatchTasksRowInterfaceController*)[self.table rowControllerAtIndex:idx];
        [row.taskNameLabel setText:task.name];
        [row.descLabel setText:task.desc];
    }];

}


- (KTPomodoroTask*)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex
{
    NSArray *tasks = [[KTCoreDataStack sharedInstance] allTasks];
    return tasks[rowIndex];
}


@end



