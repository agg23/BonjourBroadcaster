//
//  ServiceListingTopLevelItem.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/10/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceListingTopLevelItem : NSObject

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *domain;

@property (strong, nonatomic) NSArray *resolvedNames;

@property (strong, nonatomic) NSNetService *masterService;
@property (strong, nonatomic) NSArray *resolvingServices;

@end
