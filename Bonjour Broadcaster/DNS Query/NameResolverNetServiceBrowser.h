//
//  NameResolverNetServiceBrowser.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/10/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NameResolverNetServiceBrowser : NSNetServiceBrowser

@property (strong, nonatomic) NSNetService *masterService;

@end
