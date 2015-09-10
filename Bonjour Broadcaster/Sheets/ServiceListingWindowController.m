//
//  ServiceListingWindowController.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/9/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "ServiceListingWindowController.h"

#import "DNSQuerier.h"

@interface ServiceListingWindowController ()

@property (strong, nonatomic) DNSQuerier *querier;

@end

@implementation ServiceListingWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.querier = [[DNSQuerier alloc] init];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(load) userInfo:nil repeats:NO];
}

- (void)load
{
    [self.tableView reloadData];
}

#pragma mark - NSTableViewDataSource/Delegate Methods

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(row > [self.querier.detectedServices count]-1) {
        return nil;
    }
        
    if([tableColumn.identifier isEqualToString:@"service"]) {
        return [self.querier.detectedServices objectAtIndex:row];
    }
    else if([tableColumn.identifier isEqualToString:@"domain"]) {
        return nil;
    }
    
    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.querier.detectedServices count];
}

@end
