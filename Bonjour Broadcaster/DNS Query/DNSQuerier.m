//
//  DNSQuerier.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/9/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "DNSQuerier.h"

#import "ServiceListingTopLevelItem.h"
#import "NameResolverNetServiceBrowser.h"

@interface DNSQuerier ()

@property (strong, nonatomic) NSNetServiceBrowser *netServiceBrowser;
@property (strong, nonatomic) NSMutableArray *serviceNameResolvers;
@property (nonatomic) BOOL searchingTopLevel;
@property (nonatomic) NSInteger index;

@end

@implementation DNSQuerier

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.detectedServices = [NSArray array];
        self.serviceNameResolvers = [NSMutableArray array];
        
        self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
        self.netServiceBrowser.delegate = self;
        
        NSString *browseType = @"_services._dns-sd._udp.";
        
        self.searchingTopLevel = true;
        
        [self.netServiceBrowser searchForServicesOfType:browseType inDomain:@""];
    }
    return self;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSString *type = [NSString stringWithFormat:@"%@.%@", [service name], [service type]];
    type = [type substringToIndex:[type length]-7];
    
    if([browser isEqual:self.netServiceBrowser]) {
        NameResolverNetServiceBrowser *nameResolver = [[NameResolverNetServiceBrowser alloc] init];
        [nameResolver setDelegate:self];
        [nameResolver setMasterService:service];
        
        if(![self topLevelItemExistsWithServiceType:type]) {
            ServiceListingTopLevelItem *item = [[ServiceListingTopLevelItem alloc] init];
            [item setType:type];
            [item setMasterService:service];
            
            self.detectedServices = [self.detectedServices arrayByAddingObject:item];
        }
        
        [self.serviceNameResolvers addObject:nameResolver];
        
        [nameResolver searchForServicesOfType:type inDomain:@""];
    } else {
        ServiceListingTopLevelItem *item = [self topLevelItemWithNamedService:service];
        
        if(!item) {
            NSLog(@"Error, no found top level item");
            return;
        }
        
        [item setResolvedNames:[[item resolvedNames] arrayByAddingObject:[service name]]];
        [item setResolvingServices:[[item resolvingServices] arrayByAddingObject:service]];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"BonjourServiceUpdate" object:nil]];
    }
    
    if(!moreComing) {
//        [browser stop];
        
        if(![browser isEqual:self.netServiceBrowser]) {
//            [self.serviceNameResolvers removeObject:browser];
        }
    }
    
//    if(!moreComing) {
//        if(self.searchingTopLevel) {
//            self.index = 0;
//        }
//        self.searchingTopLevel = false;
//        [self.netServiceBrowser stop];
////        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
////            [self searchTest];
////        }];
//    }
}

- (ServiceListingTopLevelItem *)topLevelItemWithNamedService:(NSNetService *)namedService
{
    for(ServiceListingTopLevelItem *item in self.detectedServices) {
        if([[[item type] stringByAppendingString:@"."] isEqualToString:[namedService type]]) {
            return item;
        }
    }
    
    return nil;
}

- (BOOL)topLevelItemExistsWithServiceType:(NSString *)type
{
    NSArray *array = [NSArray arrayWithArray:self.detectedServices];
    
    for(ServiceListingTopLevelItem *item in array) {
        if([[item type] isEqualToString:type]) {
            return true;
        }
    }
    
    return false;
}

@end
