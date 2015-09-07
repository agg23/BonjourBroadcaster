//
//  ServiceEditorWindowController.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/5/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "ServiceEditorWindowController.h"

#import <QuartzCore/QuartzCore.h>

#import "BonjourHost.h"

@interface ServiceEditorWindowController ()

@end

@implementation ServiceEditorWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)saveButton:(id)sender {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    // Required input
    NSString *serviceName = [[self.serviceNameTextField stringValue] stringByTrimmingCharactersInSet:set];
    
    if([serviceName isEqualToString:@""]) {
        [self shakeWindow];
        NSBeep();
        return;
    }
    
    NSString *serviceType = [[self.serviceTypeTextField stringValue] stringByTrimmingCharactersInSet:set];
    
    if([serviceType isEqualToString:@""]) {
        [self shakeWindow];
        NSBeep();
        return;
    }
    
    NSInteger port = [[self.portTextField stringValue] integerValue];
    
    if(port == 0) {
        [self shakeWindow];
        NSBeep();
        return;
    }
    
    NSArray *enteredText = [self.textEntryTableView enteredText];
    
    BonjourService *service = [[BonjourService alloc] init];
    [service setName:serviceName];
    [service setServiceType:serviceType];
    [service setPort:port];
    [service setTxtItems:enteredText];
    
    [[BonjourHost sharedInstance] addNewService:service];
    
    [self.window orderOut:nil];
}

- (IBAction)cancelButton:(id)sender {
    [self.window orderOut:nil];
}

- (void)shakeWindow
{
    static int numberOfShakes = 3;
    static float durationOfShake = 0.4f;
    static float vigourOfShake = 0.05f;
    
    CGRect frame=[self.window frame];
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
    
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
    int index;
    for (index = 0; index < numberOfShakes; ++index)
    {
        CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) - frame.size.width * vigourOfShake, NSMinY(frame));
        CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + frame.size.width * vigourOfShake, NSMinY(frame));
    }
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = durationOfShake;
    
    [self.window setAnimations:[NSDictionary dictionaryWithObject: shakeAnimation forKey:@"frameOrigin"]];
    [[self.window animator] setFrameOrigin:[self.window frame].origin];
}

@end 
