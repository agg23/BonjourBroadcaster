//
//  TextEntryTableView.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/6/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TextEntryTableView : NSTableView <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSLayoutConstraint *heightConstraint;

@property (strong, nonatomic) NSArray *rowStrings;

- (NSArray *)enteredText;

- (void)addNewRowAfterRow:(NSView *)rowView;
- (void)removeRow:(NSView *)rowView;

@end
