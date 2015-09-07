//
//  ViewController.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/5/15.
//  Copyright (c) 2015 AppCannon Software. All rights reserved.
//

#import "ViewController.h"

#import "ServiceEditorWindowController.h"

#import "BonjourHost.h"

@interface ViewController ()

@property (strong, nonatomic) ServiceEditorWindowController *serviceEditorWindowController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[BonjourHost sharedInstance] setViewController:self];
    
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(tableViewRowClick:)];
    
    // Do view setup here.
}

- (void)showServiceEditor
{
    self.serviceEditorWindowController = [[ServiceEditorWindowController alloc] initWithWindowNibName:@"ServiceEditor"];
        
    [self.view.window beginSheet:self.serviceEditorWindowController.window completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

- (void)tableViewRowClick:(id)sender
{
    if([self.tableView clickedColumn] != [self.tableView columnWithIdentifier:@"enabled"]) {
        [self showServiceEditor];
    }
}

#pragma mark - NSTableView Methods

- (void)addRowAtIndex:(NSInteger)index
{
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexes:set withAnimation:NSTableViewAnimationEffectNone];
    [self.tableView endUpdates];
    
    [self.tableView selectRowIndexes:set byExtendingSelection:NO];
}

#pragma mark - NSTableViewDelegate/DataSource Methods

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(row > [[[BonjourHost sharedInstance] services] count]-1) {
        return;
    }
    
    BonjourService *service = [[[BonjourHost sharedInstance] services] objectAtIndex:row];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(row > [[[BonjourHost sharedInstance] services] count]-1) {
        return nil;
    }
    
    BonjourService *service = [[[BonjourHost sharedInstance] services] objectAtIndex:row];
    
    if([tableColumn.identifier isEqualToString:@"enabled"]) {
        return [NSNumber numberWithBool:service.enabled];
    }
    else if([tableColumn.identifier isEqualToString:@"name"]) {
        return service.name;
    }
    else if([tableColumn.identifier isEqualToString:@"serviceType"]) {
        return service.serviceType;
    }
    else if([tableColumn.identifier isEqualToString:@"port"]) {
        return [NSString stringWithFormat:@"%ld", service.port];
    }
    else if([tableColumn.identifier isEqualToString:@"remoteHost"]) {
        return service.remoteHost;
    }
    else if([tableColumn.identifier isEqualToString:@"remoteIP"]) {
        return service.remoteIp;
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if([tableColumn.identifier isEqualToString:@"enabled"]) {
        BonjourService *service = [[[BonjourHost sharedInstance] services] objectAtIndex:row];
        
        if([object boolValue]) {
            [[BonjourHost sharedInstance] enableService:service];
            [service setEnabled:true];
        } else {
            [service setEnabled:![[BonjourHost sharedInstance] disableService:service]];
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[[BonjourHost sharedInstance] services] count];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    if([self.tableView clickedColumn] == [self.tableView columnWithIdentifier:@"enabled"]) {
        return false;
    }
    
    return true;
}

@end
