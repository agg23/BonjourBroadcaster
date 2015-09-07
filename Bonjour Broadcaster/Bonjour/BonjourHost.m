//
//  BonjourServices.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/5/15.
//  Copyright (c) 2015 AppCannon Software. All rights reserved.
//

#import "BonjourHost.h"

#import <dns_sd.h>

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
        BonjourService *testService = [[BonjourService alloc] init];
        
        [testService setEnabled:YES];
        [testService setName:@"Test service"];
        
        self.services = @[testService];
    }
    return self;
}

- (void)addNewService:(BonjourService *)service
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.services];
    
    [array addObject:service];
    
    self.services = [NSArray arrayWithArray:array];
    
    [self.viewController addRowAtIndex:[self.services count]-1];
}

- (void)enableService:(BonjourService *)service
{
//    NSTask *task = [[NSTask alloc] init];
//    
//    [task setLaunchPath:@"/usr/bin/dns-sd"];
//    [task setArguments:@[@"-P", service.name, service.serviceType, @"local", [NSString stringWithFormat:@"%ld", service.port], @"local.", @"127.0.0.1"]];
//    
//    [task launch];
//    
//    NSLog(@"%d", [task processIdentifier]);
    
    //NSData *txtData = [self formatTxtArray:@[@"Helloworld=234", @"test=234"]];
    
    //    NSLog(@"%@", [[NSHost hostWithAddress:@"Random IP Address"] name]);

    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
    NSData *txtData = [NSNetService dataFromTXTRecordDictionary:dictionary];
    
    NSString *theTXT = [[NSString alloc] initWithBytes:txtData.bytes length:txtData.length encoding:NSASCIIStringEncoding];
    NSLog(@"%@", theTXT);
    
    const void* _txtData = [txtData bytes];
    uint16_t _txtLen = (uint16_t)txtData.length;
    
    uint16_t bigEndianPort = NSSwapHostShortToBig((uint16_t)service.port);
    
    DNSServiceFlags flags = 0;
    
    NSString *domain = @"local";
    NSString *host = @"8.8.8.8";
    
    DNSServiceRef registerRef;
    DNSServiceErrorType err = DNSServiceRegister(&registerRef, flags, kDNSServiceInterfaceIndexAny, [service.name UTF8String], [service.serviceType UTF8String], [domain UTF8String], [host UTF8String], bigEndianPort, _txtLen, _txtData, NULL, NULL);

    NSLog(@"%d", err);
    
    if(err == kDNSServiceErr_NoError)  {
        [service setServiceRef:registerRef];
    }
    
    //[task terminate];
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
