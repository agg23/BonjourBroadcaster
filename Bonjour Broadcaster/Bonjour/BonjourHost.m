//
//  BonjourServices.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/5/15.
//  Copyright (c) 2015 AppCannon Software. All rights reserved.
//

#import "BonjourHost.h"

#import <dns_sd.h>

#import "DataLoader.h"

@interface BonjourHost ()

@property (strong, nonatomic) DataLoader *dataLoader;

@end

@implementation BonjourHost

+ (BonjourHost *)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataLoader = [[DataLoader alloc] init];
        
        self.services = [self.dataLoader loadServices];
        
        if([self.services count] > 0) {
            for(BonjourService *service in self.services) {
                if(service.enabled) {
                    [self enableService:service];
                }
            }
        }
    }
    return self;
}

- (void)addNewService:(BonjourService *)service
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.services];
    
    [array addObject:service];
    
    self.services = [NSArray arrayWithArray:array];
    
    [self.viewController addRowAtIndex:[self.services count]-1];
    
    [self.dataLoader saveServices:self.services];
    
    if(service.enabled) {
        [self enableService:service];
    }
}

- (void)updateService:(BonjourService *)service
{
    if(service.serviceRef) {
        [self disableService:service];
        [self enableService:service];
    }
    
    [self.dataLoader saveServices:self.services];
}

- (void)removeService:(BonjourService *)service
{
    NSInteger index = [self.services indexOfObject:service];
    
    if(index != NSNotFound) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.services];
        
        [array removeObjectAtIndex:index];
        
        self.services = [NSArray arrayWithArray:array];
    }
    
    [self disableService:service];
    
    [self.dataLoader saveServices:self.services];
}

- (void)enableService:(BonjourService *)service
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    for(NSString *string in service.txtItems) {
        [dictionary addEntriesFromDictionary:[self stringToDictionaryWithString:string]];
    }
        
    NSData *txtData = [NSNetService dataFromTXTRecordDictionary:dictionary];
    
    const void* txtBytes = [txtData bytes];
    uint16_t txtLen = (uint16_t)txtData.length;
    
    uint16_t bigEndianPort = NSSwapHostShortToBig((uint16_t)service.port);
    
    DNSServiceFlags flags = 0;
    
    NSString *domain = nil;
    NSString *host = nil;
    
    if(service.remoteEnabled && service.remoteHost && ![service.remoteHost isEqualToString:@""]) {
        domain = @"local";
        
        host = service.remoteHost;
    }
    
    DNSServiceRef registerRef;
    DNSServiceErrorType err = DNSServiceRegister(&registerRef, flags, kDNSServiceInterfaceIndexAny, [service.name UTF8String], [service.serviceType UTF8String], [domain UTF8String], [host UTF8String], bigEndianPort, txtLen, txtBytes, NULL, NULL);

    NSLog(@"%d", err);
    
    if(err == kDNSServiceErr_NoError)  {
        [service setServiceRef:registerRef];
        
        [service setEnabled:YES];
        
        [self.dataLoader saveServices:self.services];
    } else {
        [service setEnabled:NO];
    }
}

- (BOOL)disableService:(BonjourService *)service
{
    NSLog(@"Disabling service: %@", [service name]);
    
    DNSServiceRef serviceRef = [service serviceRef];
    
    if(!serviceRef) {
        return false;
    }
    
    DNSServiceRefDeallocate(serviceRef);
    
    NSLog(@"Service %@ disabled", [service name]);
    
    [self.dataLoader saveServices:self.services];
    
    return true;
}

- (NSDictionary *)stringToDictionaryWithString:(NSString *)string
{
    NSArray *array = [string componentsSeparatedByString:@"="];
    
    if([array count] <= 1) {
        return nil;
    }
    
    return [NSDictionary dictionaryWithObject:[array objectAtIndex:1] forKey:[array objectAtIndex:0]];
}

- (NSData *)formatTxtArray:(NSArray *)array
{
    NSMutableData *data = [NSMutableData data];
    
    for(NSString *string in array) {
//        const char *cString = [string UTF8String];
//        
//        [data appendBytes:cString length:sizeof(cString)];
        
        char *characters = (char *)malloc([string length]);
        [string getCString:characters maxLength:sizeof(characters) encoding:NSUTF8StringEncoding];
        [data appendBytes:&characters length:sizeof(characters)];
    }
    
    return [NSData dataWithData:data];
}

@end
