//
//  DNSQuerier.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/9/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "DNSQuerier.h"

#import "ServiceListingTopLevelItem.h"
#import "ServiceListingChildItem.h"
#import "NameResolverNetServiceBrowser.h"

@interface DNSQuerier ()

@property (strong, nonatomic) NSNetServiceBrowser *netServiceBrowser;
@property (strong, nonatomic) NSMutableArray *serviceNameResolvers;
@property (nonatomic) BOOL searchingTopLevel;
@property (nonatomic) NSInteger index;

@property (strong, nonatomic) NSArray *knownServices;

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
        
        [self loadKnownServices];
        
        NSString *browseType = @"_services._dns-sd._udp.";
        
        self.searchingTopLevel = true;
        
        [self.netServiceBrowser searchForServicesOfType:browseType inDomain:@""];
    }
    return self;
}

- (void)loadKnownServices
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Services" ofType:@"plist"];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    self.knownServices = [dictionary objectForKey:@"Services"];
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
            
            NSString *typeWithPeriod = [type stringByAppendingString:@"."];
            NSString *humanReadableType = [self humanReadableTypeStringForServiceType:typeWithPeriod];
            
            if(humanReadableType) {
                [item setHumanReadableType:humanReadableType];
            }
            
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
        
        ServiceListingChildItem *childItem = [[ServiceListingChildItem alloc] init];
        [childItem setName:[service name]];
        [childItem setParentItem:item];
        [childItem setResolvingService:service];
        
        [item setChildren:[[item children] arrayByAddingObject:childItem]];
        
        [item setResolvingServices:[[item resolvingServices] arrayByAddingObject:service]];
        
        [service resolveWithTimeout:1.0f];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"BonjourServiceUpdate" object:nil]];
    }
    
    if(!moreComing) {
        if(![browser isEqual:self.netServiceBrowser]) {
            // Sort array, with named items on top, and unnamed services below
            self.detectedServices = [self.detectedServices sortedArrayUsingComparator:^NSComparisonResult(ServiceListingTopLevelItem *obj1, ServiceListingTopLevelItem *obj2) {
                NSString *compareType1 = [obj1 humanReadableType];
                NSString *compareType2 = [obj2 humanReadableType];
                
                BOOL humanReadable1 = true;
                BOOL humanReadable2 = true;
                
                if(!compareType1) {
                    compareType1 = [obj1 type];
                    humanReadable1 = false;
                }
                
                if(!compareType2) {
                    compareType2 = [obj2 type];
                    humanReadable2 = false;
                }
                
                if(humanReadable1) {
                    if(humanReadable2) {
                        return [compareType1 compare:compareType2];
                    } else {
                        return NSOrderedAscending;
                    }
                }
                
                if(humanReadable2) {
                    return NSOrderedDescending;
                }
                
                return [compareType1 compare:compareType2];
            }];
        }
    }
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

- (NSString *)humanReadableTypeStringForServiceType:(NSString *)type
{
    for(NSDictionary *dictionary in self.knownServices) {
        if([[dictionary objectForKey:@"Service"] isEqualToString:type]) {
            return [dictionary objectForKey:@"Name"];
        }
    }
    
    return nil;
}

@end
