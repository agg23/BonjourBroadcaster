//
//  TextEntryRowView.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/6/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "TextEntryRowView.h"

@implementation TextEntryRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


- (IBAction)removeButton:(id)sender {
    [self.tableView removeRow:self];
}

- (IBAction)addButton:(id)sender {
    [self.tableView addNewRowAfterRow:self];
}

@end
