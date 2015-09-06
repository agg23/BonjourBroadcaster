//
//  BonjourServices.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/5/15.
//  Copyright (c) 2015 AppCannon Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BonjourService.h"

@interface BonjourHost : NSObject

@property (strong, nonatomic) NSArray *services;

+ (id)sharedInstance;

@end
