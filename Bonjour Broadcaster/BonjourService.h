//
//  BonjourService.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/5/15.
//  Copyright (c) 2015 AppCannon Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BonjourService : NSObject

@property (strong, nonatomic) NSString *name;
@property (nonatomic) BOOL enabled;

@property (strong, nonatomic) NSString *serviceType;

@property (strong, nonatomic) NSString *remoteHost;
@property (strong, nonatomic) NSString *remoteIp;

@property (strong, nonatomic) NSArray *txtItems;

@end
