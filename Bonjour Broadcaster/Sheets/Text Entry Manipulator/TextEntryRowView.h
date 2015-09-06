//
//  TextEntryRowView.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/6/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TextEntryTableView.h"

@interface TextEntryRowView : NSView

@property (weak) TextEntryTableView *tableView;

@property (weak) IBOutlet NSTextField *textfield;

@property (weak) IBOutlet NSButton *removeButton;
@property (weak) IBOutlet NSButton *addButton;

@property (nonatomic) NSInteger row;

@end
