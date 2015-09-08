//
//  BonjourServices.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/5/15.
//  Copyright (c) 2015 AppCannon Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BonjourService.h"

#import "ViewController.h"

@interface BonjourHost : NSObject

@property (weak) ViewController *viewController;

@property (strong, nonatomic) NSArray *services;

+ (BonjourHost *)sharedInstance;

- (void)addNewService:(BonjourService *)service;
- (void)updateService:(BonjourService *)service;
- (void)removeService:(BonjourService *)service;

- (void)enableService:(BonjourService *)service;
- (BOOL)disableService:(BonjourService *)service;

@end
