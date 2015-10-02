//
//  ReachabilityController.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 10/1/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Reachability.h"

@interface ReachabilityController : NSObject

- (void)addServer:(NSString *)serverHostName;

@end
