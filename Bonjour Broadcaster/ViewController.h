//
//  ViewController.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/5/15.
//  Copyright (c) 2015 AppCannon Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BonjourService.h"

@interface ViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *tableView;

- (void)addRowAtIndex:(NSInteger)index;

- (void)showServiceEditorAndEditService:(BonjourService *)service shouldAddToDisplay:(BOOL)add;

@end
