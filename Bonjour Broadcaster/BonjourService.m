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

+ (id)serviceFromDictionary:(NSDictionary *)dictionary
{
    BonjourService *service = [[self alloc] init];
    
    NSString *name = [dictionary objectForKey:@"name"];
    NSNumber *enabled = [dictionary objectForKey:@"enabled"];
    
    NSString *serviceType = [dictionary objectForKey:@"serviceType"];
    NSNumber *port = [dictionary objectForKey:@"port"];
    
    if(!name || [name isEqualToString:@""] || !enabled ||
       !serviceType || [serviceType isEqualToString:@""] || !port) {
        return nil;
    }
    
    [service setName:name];
    [service setEnabled:[enabled boolValue]];
    
    [service setServiceType:serviceType];
    [service setPort:[port integerValue]];
    
    NSNumber *remoteEnabled = [dictionary objectForKey:@"remoteEnabled"];
    
    if(remoteEnabled) {
        [service setRemoteEnabled:[remoteEnabled boolValue]];
    }
    
    NSString *remoteHost = [dictionary objectForKey:@"remoteHost"];
    [service setRemoteHost:remoteHost];
    
    NSString *remoteIp = [dictionary objectForKey:@"remoteIp"];
    [service setRemoteIp:remoteIp];
    
    NSArray *txtItems = [dictionary objectForKey:@"txtItems"];
    [service setTxtItems:txtItems];
    
    return service;
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

- (NSDictionary *)encodeToDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setObject:self.name forKey:@"name"];
    [dictionary setObject:[NSNumber numberWithBool:self.enabled] forKey:@"enabled"];
    
    [dictionary setObject:self.serviceType forKey:@"serviceType"];
    [dictionary setObject:[NSNumber numberWithInteger:self.port] forKey:@"port"];
    
    [dictionary setObject:[NSNumber numberWithBool:self.remoteEnabled] forKey:@"remoteEnabled"];
    if(self.remoteHost) {
        [dictionary setObject:self.remoteHost forKey:@"remoteHost"];
    }
    
    if(self.remoteIp) {
        [dictionary setObject:self.remoteIp forKey:@"remoteIp"];
    }
    
    [dictionary setObject:self.txtItems forKey:@"txtItems"];
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

@end
