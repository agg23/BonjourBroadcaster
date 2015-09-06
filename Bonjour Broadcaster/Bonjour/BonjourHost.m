//
//  BonjourServices.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/5/15.
//  Copyright (c) 2015 AppCannon Software. All rights reserved.
//

#import "BonjourHost.h"

@implementation BonjourHost

+ (id)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        BonjourService *testService = [[BonjourService alloc] init];
        
        [testService setEnabled:YES];
        [testService setName:@"Test service"];
        
        self.services = @[testService];
    }
    return self;
}

@end
