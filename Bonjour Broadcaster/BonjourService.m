//
//  BonjourService.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/5/15.
//  Copyright (c) 2015 AppCannon Software. All rights reserved.
//

#import "BonjourService.h"

@implementation BonjourService

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if(self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.enabled = [aDecoder decodeBoolForKey:@"enabled"];
        
        self.serviceType = [aDecoder decodeObjectForKey:@"serviceType"];
        self.port = [aDecoder decodeIntegerForKey:@"port"];
        
        self.remoteEnabled = [aDecoder decodeBoolForKey:@"remoteEnabled"];
        self.remoteHost = [aDecoder decodeObjectForKey:@"remoteHost"];
        self.remoteIp = [aDecoder decodeObjectForKey:@"remoteIp"];
        
        self.txtItems = [aDecoder decodeObjectForKey:@"txtItems"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeBool:self.enabled forKey:@"enabled"];
    
    [encoder encodeObject:self.serviceType forKey:@"serviceType"];
    [encoder encodeInteger:self.port forKey:@"port"];
    
    [encoder encodeBool:self.remoteEnabled forKey:@"remoteEnabled"];
    [encoder encodeObject:self.remoteHost forKey:@"remoteHost"];
    [encoder encodeObject:self.remoteIp forKey:@"remoteIp"];
    
    [encoder encodeObject:self.txtItems forKey:@"txtItems"];
}

@end
