//
//  ServiceListingChildItem.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/11/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ServiceListingTopLevelItem.h"

@interface ServiceListingChildItem : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) ServiceListingTopLevelItem *parentItem;

@property (strong, nonatomic) NSNetService *resolvingService;

@property (strong, nonatomic) NSArray *txtRecords;
@property (strong, nonatomic) NSArray *addresses;

@end
