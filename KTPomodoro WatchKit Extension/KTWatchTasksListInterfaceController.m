//
//  KTWatchTasksListInterfaceController.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/1/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTWatchTasksListInterfaceController.h"
#import "KTCoreDataStack.h"
#import "KTPomodoroActivityModel.h"
#import "KTPomodoroTaskConstants.h"
#import "KTWatchTasksRowInterfaceController.h"
#import "KTWatchAddTaskRowInterfaceController.h"

@interface KTWatchTasksListInterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@property (nonatomic) NSArray *allTasks;

@end


@implementation KTWatchTasksListInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
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

    // if tasks count changed, reload table
    if ([tasks count] != [self.allTasks count]) {
        self.allTasks = tasks;
        [self clearTableRows];

        [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tasks count])] withRowType:@"KTWatchTasksRowInterfaceController"];
        __block CGFloat cellAlpha = 1.0f;
        [tasks enumerateObjectsUsingBlock:^(KTPomodoroActivityModel *task, NSUInteger idx, BOOL *stop) {
            KTWatchTasksRowInterfaceController *row = (KTWatchTasksRowInterfaceController*)[self.table rowControllerAtIndex:idx];
            [row.taskNameLabel setText:task.name];
            [row.rowGroup setCornerRadius:0.0f];
            [row.rowGroup setAlpha:cellAlpha];
            if (cellAlpha > 0.2f) {
                cellAlpha -= 0.2;
            }
            if (idx > 0) {
                [row.taskStatusLabel setHidden:YES];
            }
        }];


        // add "add task" row at end
        [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([tasks count], 1)] withRowType:@"KTWatchAddTaskRowInterfaceController"];

    }
}

- (void)clearTableRows
{
    [self.table removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.table numberOfRows])]];
}


- (KTPomodoroActivityModel*)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex
{
    if ([segueIdentifier isEqualToString:@"taskDetailsSegue"]) {
        return self.allTasks[rowIndex];
    } else {
        return nil;
    }
}

#pragma mark - helper


@end



