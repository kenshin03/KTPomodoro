//
//  KTActiveActivityState.m
//  KTPomodoro
//
//  Created by Kenny Tang on 1/22/15.
//  Copyright (c) 2015 Kenny Tang. All rights reserved.
//

#import "KTActiveActivityState.h"

@implementation KTActiveActivityState

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.activityID forKey:@"activityID"];
    [encoder encodeObject:self.status forKey:@"status"];
    [encoder encodeObject:self.currentPomo forKey:@"currentPomo"];
    [encoder encodeObject:self.elapsedSecs forKey:@"elapsedSecs"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.activityID = [decoder decodeObjectForKey:@"activityID"];
        self.status = [decoder decodeObjectForKey:@"status"];
        self.currentPomo = [decoder decodeObjectForKey:@"currentPomo"];
        self.elapsedSecs = [decoder decodeObjectForKey:@"elapsedSecs"];
    }
    return self;
}

@end
