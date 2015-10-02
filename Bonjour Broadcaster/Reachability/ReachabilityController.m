//
//  ReachabilityController.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 10/1/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "ReachabilityController.h"

@implementation ReachabilityController

- (void)addServer:(NSString *)serverHostName
{
    Reachability *reach = [Reachability reachabilityWithHostname:@"appcannonserver.reshall.rose-hulman.edu"];
    
    reach.reachableBlock = ^(Reachability *reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
        });
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        NSLog(@"UNREACHABLE!");
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
}

@end
