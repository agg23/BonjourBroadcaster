//
//  ServiceListingWindowController.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/9/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "ServiceListingWindowController.h"

#import "ServiceListingTopLevelItem.h"

#import "DNSQuerier.h"

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

#pragma mark - NSTableViewDataSource/Delegate Methods

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if(item && [item isKindOfClass:[ServiceListingTopLevelItem class]]) {
        // Children of given item
        return @"";
    } else if(item == nil) {
        return [self.topLevelItems objectAtIndex:index];
    }
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return YES;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    return [self.topLevelItems count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if(!item || ![item isKindOfClass:[ServiceListingTopLevelItem class]]) {
        return @"";
    }
    
    if([tableColumn.identifier isEqualToString:@"service"]) {
        return [(ServiceListingTopLevelItem *)item type];
    }
    else if([tableColumn.identifier isEqualToString:@"domain"]) {
        return [(ServiceListingTopLevelItem *)item domain];
    }
    
    return @"";
}

@end
