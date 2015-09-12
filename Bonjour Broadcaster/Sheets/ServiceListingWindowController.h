//
//  ServiceListingWindowController.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/9/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ServiceListingWindowController : NSWindowController <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (weak) NSViewController *viewController;

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSButton *duplicateButton;

@end
