//
//  AppDelegate.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/5/15.
//  Copyright (c) 2015 AppCannon Software. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusBarItem setTitle:@"B"];
    [self.statusBarItem setHighlightMode:YES];
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Show Bonjour Browser" action:@selector(showBrowser:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit Bonjour Browser" action:@selector(quit:) keyEquivalent:@""];
    
    [self.statusBarItem setMenu:menu];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)showBrowser:(id)sender
{
    [self.window makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)quit:(id)sender
{
    [[NSApplication sharedApplication] terminate:nil];
}

@end
