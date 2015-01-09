//
//  KTWatchTaskCompletedNotificationController.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/9/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTWatchTaskCompletedNotificationController.h"


@interface KTWatchTaskCompletedNotificationController()

@property (nonatomic) IBOutlet WKInterfaceLabel *alertLabel;
@property (nonatomic) IBOutlet WKInterfaceLabel *plannedPomosLabel;
@property (nonatomic) IBOutlet WKInterfaceLabel *actualPomosLabel;
@property (nonatomic) IBOutlet WKInterfaceLabel *interruptionsLabel;

@end


@implementation KTWatchTaskCompletedNotificationController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)didReceiveLocalNotification:(UILocalNotification *)localNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {


    NSLog(@"didReceiveLocalNotification");

    // This method is called when a local notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification inteface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}

- (void)didReceiveRemoteNotification:(NSDictionary *)remoteNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {

    NSLog(@"didReceiveRemoteNotification");

    NSString *alertString = remoteNotification[@"aps"][@"alert"];

    NSDictionary *payload = remoteNotification[@"payload"];
    //    NSString *taskID = payload[@"id"];
//    NSString *taskName = payload[@"name"];
    NSNumber *plannedPomos = payload[@"planned_pomos"];
    NSNumber *actualPomos = payload[@"actual_pomos"];
    NSNumber *interrupts = payload[@"interrupts"];

    [self.plannedPomosLabel setText:[plannedPomos stringValue]];
    [self.actualPomosLabel setText:[actualPomos stringValue]];
    [self.interruptionsLabel setText:[interrupts stringValue]];

    [self.alertLabel setText:alertString];


    completionHandler(WKUserNotificationInterfaceTypeCustom);
}

@end



