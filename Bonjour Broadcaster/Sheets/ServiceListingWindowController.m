//
//  ServiceListingWindowController.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/9/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "ServiceListingWindowController.h"

#import "ViewController.h"

#import "ServiceListingTopLevelItem.h"
#import "ServiceListingChildItem.h"
#import "ServiceListingAddressItem.h"

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

- (IBAction)reloadButton:(id)sender {
    [self.querier reload];
}

- (IBAction)duplicateButton:(id)sender {
    ServiceListingChildItem *item = [self.outlineView itemAtRow:[self.outlineView selectedRow]];
    
    BonjourService *service = [self serviceFromChildItem:item];
    
    [self.window orderOut:nil];
    [(ViewController *)self.viewController showServiceEditorAndEditService:service];
}

#pragma mark - NSOutlineViewDataSource/Delegate Methods

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if(item) {
        if([item isKindOfClass:[ServiceListingTopLevelItem class]]) {
            // Children of given item
            ServiceListingChildItem *childItem = [[(ServiceListingTopLevelItem *)item children] objectAtIndex:index];
            
            [self sortAddressesAndTxtRecordsIfNeeded:childItem];

            return childItem;
        } else if([item isKindOfClass:[ServiceListingChildItem class]]) {
            // Children of given item
            ServiceListingChildItem *childItem = (ServiceListingChildItem *)item;
            
            NSNetService *resolvingService = [childItem resolvingService];
            NSInteger addressCount = [[resolvingService addresses] count];
            
            [self sortAddressesAndTxtRecordsIfNeeded:childItem];

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
            
            [self sortAddressesAndTxtRecordsIfNeeded:childItem];
            
            return addressCount + [[childItem txtRecords] count];
        }
    }
    
    return [self.topLevelItems count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if(!item || (![item isKindOfClass:[ServiceListingTopLevelItem class]] && ![item isKindOfClass:[NSString class]]
                 && ![item isKindOfClass:[ServiceListingChildItem class]] && ![item isKindOfClass:[ServiceListingAddressItem class]])) {
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
        } else if([item isKindOfClass:[ServiceListingAddressItem class]]) {
            return [item address];
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

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if(!item || ![item isKindOfClass:[ServiceListingAddressItem class]]) {
        return;
    }
    
    NSString *string = [cell stringValue];
    
    NSColor *textColor = [NSColor colorWithCalibratedWhite:0.4f alpha:1.0f];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:textColor, NSForegroundColorAttributeName, nil];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:dictionary];
    
    [cell setAttributedStringValue:attributedString];
}

- (NSIndexSet *)outlineView:(NSOutlineView *)outlineView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
    if([proposedSelectionIndexes lastIndex] - [proposedSelectionIndexes firstIndex] > 1) {
        return [outlineView selectedRowIndexes];
    }
    
    NSInteger row = [proposedSelectionIndexes firstIndex];
    
    id item = [outlineView itemAtRow:row];
    
    if([item isKindOfClass:[ServiceListingChildItem class]]) {
        [self.duplicateButton setEnabled:YES];
    } else {
        [self.duplicateButton setEnabled:NO];
    }
    
    return proposedSelectionIndexes;
}

#pragma mark - Utility Methods

- (void)sortAddressesAndTxtRecordsIfNeeded:(ServiceListingChildItem *)childItem
{
    if(![childItem addresses]) {
        NSArray *array = [self addressArrayFromAddressDataArray:[[childItem resolvingService] addresses]];
        
        [childItem setAddresses:array];
    }
    
    if(![childItem txtRecords]) {
        NSDictionary *dictionary = [NSNetService dictionaryFromTXTRecordData:[[childItem resolvingService] TXTRecordData]];
        
        if(dictionary) {
            NSArray *array = [self txtArrayFromDictionary:dictionary];
            
            [childItem setTxtRecords:array];
        }
    }
}

- (BonjourService *)serviceFromChildItem:(ServiceListingChildItem *)childItem
{
    BonjourService *service = [[BonjourService alloc] init];
    
    [service setName:[[childItem name] stringByAppendingString:@" Copy"]];
    [service setServiceType:[[childItem parentItem] type]];
    [service setTxtItems:[childItem txtRecords]];
    
    if([[childItem addresses] count] > 0) {
        ServiceListingAddressItem *addressItem = [[childItem addresses] objectAtIndex:0];
        
        [service setPort:[addressItem port]];
        [service setRemoteIp:[addressItem rawIp]];
    }
    
    return service;
}

- (NSArray *)addressArrayFromAddressDataArray:(NSArray *)array
{
    NSMutableArray *addressArray = [NSMutableArray array];
    
    for(NSData *data in array) {
        // Thanks to http://stackoverflow.com/questions/13396892/getting-sockaddr-in-from-cfdataref
        
        int port=0;
        struct sockaddr *addressGeneric = (struct sockaddr *) [data bytes];
        NSString *addressString = @"";
        NSString *rawIp = @"";
        
        switch( addressGeneric->sa_family ) {
            case AF_INET: {
                struct sockaddr_in *ip4;
                char dest[INET_ADDRSTRLEN];
                ip4 = (struct sockaddr_in *) [data bytes];
                port = ntohs(ip4->sin_port);
                rawIp = [NSString stringWithFormat:@"%s", inet_ntop(AF_INET, &ip4->sin_addr, dest, sizeof dest)];
                addressString = [NSString stringWithFormat: @"%@:%d", rawIp, port];
            }
                break;
                
            case AF_INET6: {
                struct sockaddr_in6 *ip6;
                char dest[INET6_ADDRSTRLEN];
                ip6 = (struct sockaddr_in6 *) [data bytes];
                port = ntohs(ip6->sin6_port);
                rawIp = [NSString stringWithFormat:@"%s", inet_ntop(AF_INET6, &ip6->sin6_addr, dest, sizeof dest)];
                addressString = [NSString stringWithFormat: @"[%@]:%d", rawIp, port];
            }
                break;
            default:
                addressString=@"Error on get family type.";
                break;
        }
        
        ServiceListingAddressItem *item = [[ServiceListingAddressItem alloc] init];
        [item setAddress:addressString];
        [item setRawIp:rawIp];
        [item setPort:port];
        
        [addressArray addObject:item];
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
