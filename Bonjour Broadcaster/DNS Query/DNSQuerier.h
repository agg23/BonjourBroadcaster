//
//  DNSQuerier.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/9/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNSQuerier : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (strong, nonatomic) NSArray *detectedServices;

- (void)reload;

@end
