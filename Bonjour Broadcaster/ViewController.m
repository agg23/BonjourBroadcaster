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
    
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(tableViewRowClick:)];
    
    // Do view setup here.
}

- (void)showServiceEditor
{
    self.serviceEditorWindowController = [[ServiceEditorWindowController alloc] initWithWindowNibName:@"ServiceEditor"];
    
    NSLog(@"%@", self.serviceEditorWindowController.window);
    
    [self.view.window beginSheet:self.serviceEditorWindowController.window completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

- (void)tableViewRowClick:(id)sender
{
    [self showServiceEditor];
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
    
    return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[[BonjourHost sharedInstance] services] count];
}

@end
