//
//  KTCoreDataStack.h
//  KTPomodoro
//
//  Created by Kenny Tang on 12/31/14.
//  Copyright (c) 2014 Kenny Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "KTPomodoroTask.h"

@interface KTCoreDataStack : NSObject

+ (KTCoreDataStack*)sharedInstance;

- (NSArray*)allTasks;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (KTPomodoroTask*)createNewTask:(NSString*)taskName taskDesc:(NSString*)description pomodoros:(NSUInteger)pomodoros;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
