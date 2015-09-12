//
//  ServiceListingWindowController.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/9/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "ServiceListingWindowController.h"

#import "ServiceListingTopLevelItem.h"
#import "ServiceListingChildItem.h"

#import "DNSQuerier.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@interface ServiceListingWindowController ()

@property (strong, nonatomic) DNSQuerier *querier;

@property (strong, nonatomic) NSArray *topLevelItems;

@end

@implementation ServiceListingWindowController

- (instancetype)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        self.querier = [[DNSQuerier alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(load) name:@"BonjourServiceUpdate" object:nil];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)load
{
    self.topLevelItems = [NSArray arrayWithArray:self.querier.detectedServices];
    
    [self.outlineView reloadData];
}

#pragma mark - NSOutlineViewDataSource/Delegate Methods

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if(item) {
        if([item isKindOfClass:[ServiceListingTopLevelItem class]]) {
            // Children of given item
            ServiceListingChildItem *childItem = [[(ServiceListingTopLevelItem *)item children] objectAtIndex:index];
            return childItem;
        } else if([item isKindOfClass:[ServiceListingChildItem class]]) {
            // Children of given item
            ServiceListingChildItem *childItem = (ServiceListingChildItem *)item;
            
            NSNetService *resolvingService = [childItem resolvingService];
            NSInteger addressCount = [[resolvingService addresses] count];

            if(index < addressCount) {
                return [[childItem addresses] objectAtIndex:index];
            }
            
            NSString *recordString = [[childItem txtRecords] objectAtIndex:index-addressCount];
            
            return recordString;
        }
    } else if(item == nil) {
        return [self.topLevelItems objectAtIndex:index];
    }
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if(item) {
        if([item isKindOfClass:[ServiceListingTopLevelItem class]]) {
            return [[(ServiceListingTopLevelItem *)item children] count];
        } else if([item isKindOfClass:[ServiceListingChildItem class]]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if(item) {
        // Children of given item
        if([item isKindOfClass:[ServiceListingTopLevelItem class]]) {
            return [[(ServiceListingTopLevelItem *)item children] count];
        } else if([item isKindOfClass:[ServiceListingChildItem class]]) {
            ServiceListingChildItem *childItem = (ServiceListingChildItem *)item;
            
            NSNetService *resolvingService = [childItem resolvingService];
            NSInteger addressCount = [[resolvingService addresses] count];
            
            if(![childItem addresses]) {
                NSArray *array = [self addressStringArrayFromAddressDataArray:[resolvingService addresses]];
                
                [childItem setAddresses:array];
            }
            
            if(![childItem txtRecords]) {
                NSDictionary *dictionary = [NSNetService dictionaryFromTXTRecordData:[resolvingService TXTRecordData]];
                
                if(dictionary) {
                    NSArray *array = [self txtArrayFromDictionary:dictionary];
                    
                    [childItem setTxtRecords:array];
                }
            }
            
            return addressCount + [[childItem txtRecords] count];
        }
    }
    
    return [self.topLevelItems count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if(!item || (![item isKindOfClass:[ServiceListingTopLevelItem class]] && ![item isKindOfClass:[NSString class]] && ![item isKindOfClass:[ServiceListingChildItem class]])) {
        return @"";
    }
    
    if([tableColumn.identifier isEqualToString:@"service"]) {
        if([item isKindOfClass:[ServiceListingTopLevelItem class]]) {
            ServiceListingTopLevelItem *topLevelItem = (ServiceListingTopLevelItem *)item;
            
            if([topLevelItem humanReadableType]) {
                return [topLevelItem humanReadableType];
            }
            
            return [(ServiceListingTopLevelItem *)item type];
        } else if([item isKindOfClass:[ServiceListingChildItem class]]) {
            return [item name];
        } else if([item isKindOfClass:[NSString class]]) {
            return item;
        }
    }
    else if([tableColumn.identifier isEqualToString:@"domain"]) {
        if([item isKindOfClass:[ServiceListingTopLevelItem class]]) {
            return [(ServiceListingTopLevelItem *)item domain];
        }
    }
    
    return @"";
}

#pragma mark - Utility Methods

- (NSArray *)addressStringArrayFromAddressDataArray:(NSArray *)array
{
    NSMutableArray *addressArray = [NSMutableArray array];
    
    for(NSData *data in array) {
        int port=0;
        struct sockaddr *addressGeneric = (struct sockaddr *) [data bytes];
        NSString *addressString = @"";
        
        switch( addressGeneric->sa_family ) {
            case AF_INET: {
                struct sockaddr_in *ip4;
                char dest[INET_ADDRSTRLEN];
                ip4 = (struct sockaddr_in *) [data bytes];
                port = ntohs(ip4->sin_port);
                addressString = [NSString stringWithFormat: @"IP4: %s Port: %d", inet_ntop(AF_INET, &ip4->sin_addr, dest, sizeof dest),port];
            }
                break;
                
            case AF_INET6: {
                struct sockaddr_in6 *ip6;
                char dest[INET6_ADDRSTRLEN];
                ip6 = (struct sockaddr_in6 *) [data bytes];
                port = ntohs(ip6->sin6_port);
                addressString = [NSString stringWithFormat: @"IP6: %s Port: %d",  inet_ntop(AF_INET6, &ip6->sin6_addr, dest, sizeof dest),port];
            }
                break;
            default:
                addressString=@"Error on get family type.";
                break;
        }
        
        [addressArray addObject:addressString];
    }
    
    return [NSArray arrayWithArray:addressArray];
}

- (NSArray *)txtArrayFromDictionary:(NSDictionary *)dictionary
{
    NSArray *sortedKeys = [[dictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for(NSString *key in sortedKeys) {
        NSData *data = [dictionary objectForKey:key];
        
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSString *recordString = [NSString stringWithFormat:@"%@=%@", key, dataString];
        
        [array addObject:recordString];
    }
    
    return [NSArray arrayWithArray:array];
}

@end
