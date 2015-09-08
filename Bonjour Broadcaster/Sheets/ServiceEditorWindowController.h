//
//  ServiceEditorWindowController.h
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/5/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TextEntryTableView.h"

#import "BonjourService.h"

@interface ServiceEditorWindowController : NSWindowController

@property (weak) IBOutlet NSTextField *serviceNameTextField;
@property (weak) IBOutlet NSTextField *serviceTypeTextField;
@property (weak) IBOutlet NSTextField *portTextField;

@property (weak) IBOutlet TextEntryTableView *textEntryTableView;

@property (weak) IBOutlet NSButton *remoteHostCheckBox;

@property (weak) IBOutlet NSTextField *hostNameTextField;
@property (weak) IBOutlet NSTextField *ipAddressTextField;

- (void)editService:(BonjourService *)service;

@end
