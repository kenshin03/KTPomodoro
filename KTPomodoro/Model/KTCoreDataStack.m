//
//  KTCoreDataStack.m
//  KTPomodoro
//
//  Created by Kenny Tang on 12/31/14.
//  Copyright (c) 2014 Kenny Tang. All rights reserved.
//

#import "KTCoreDataStack.h"
#import "KTPomodoroTaskConstants.h"


@implementation KTCoreDataStack

+ (KTCoreDataStack*)sharedInstance
{
    static KTCoreDataStack* _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [KTCoreDataStack new];
        [_instance seedData];
    });
    return _instance;
}

#pragma mark - Helpers

- (KTPomodoroTask*)createNewTask:(NSString*)taskName taskDesc:(NSString*)description pomodoros:(NSUInteger)pomodoros
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"KTPomodoroTask" inManagedObjectContext:self.managedObjectContext];

    KTPomodoroTask *newTask1 = (KTPomodoroTask*)[[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
    newTask1.name = taskName;
    newTask1.desc = description;
    newTask1.status = @(KTPomodoroTaskStatusStopped);
    newTask1.expected_pomo = @(pomodoros);
    newTask1.actual_pomo = @(0);
    newTask1.created_time = [NSDate new];

    return newTask1;
}

- (void)seedData
{
    if (![[self allTasks] count]) {

        // Create Managed Object
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"KTPomodoroTask" inManagedObjectContext:self.managedObjectContext];

        KTPomodoroTask *newTask1 = (KTPomodoroTask*)[[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
        newTask1.name = @"Task 1";
        newTask1.desc = @"Task desc";
        newTask1.status = @(KTPomodoroTaskStatusStopped);
        newTask1.expected_pomo = @(1);
        newTask1.actual_pomo = @(0);
        newTask1.created_time = [NSDate new];

        KTPomodoroTask *newTask2 = (KTPomodoroTask*)[[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
        newTask2.name = @"Task 2";
        newTask2.desc = @"Task desc";
        newTask2.status = @(KTPomodoroTaskStatusStopped);
        newTask2.expected_pomo = @(1);
        newTask2.actual_pomo = @(0);
        newTask2.created_time = [NSDate new];

    }
}

- (NSArray*)allTasks
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"KTPomodoroTask"];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_time" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];

    NSArray* objects = [self.managedObjectContext executeFetchRequest:request error:NULL];
    return objects;
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.corgitoergosum.KTPomodoro" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"KTPomodoroModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    // Create the coordinator and store

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSString *appGroupID = @"group.com.corgitoergosum.KTPomodoro";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appGroupURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:appGroupID];

//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"KTPomodoro.sqlite"];

    NSURL *storeURL = [appGroupURL URLByAppendingPathComponent:@"KTPomodoro.sqlite"];

    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
