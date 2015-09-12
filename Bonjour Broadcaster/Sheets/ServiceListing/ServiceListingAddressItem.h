//
//  ServiceListingAddressItem.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/11/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceListingAddressItem : NSObject

@property (strong, nonatomic) NSString *address;

@property (strong, nonatomic) NSString *rawIp;

@property (nonatomic) NSInteger port;

@end
