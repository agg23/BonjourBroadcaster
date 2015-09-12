//
//  ServiceListingTopLevelItem.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/10/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "ServiceListingTopLevelItem.h"

@implementation ServiceListingTopLevelItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.children = [NSArray array];
        self.resolvingServices = [NSArray array];
    }
    return self;
}

@end
