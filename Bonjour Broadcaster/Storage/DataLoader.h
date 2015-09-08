//
//  DataLoader.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/7/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataLoader : NSObject

- (NSArray *)loadServices;
- (void)saveServices:(NSArray *)services;

@end
