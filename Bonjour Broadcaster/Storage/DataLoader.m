//
//  DataLoader.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/7/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "DataLoader.h"

@interface DataLoader ()

@property (weak) NSUserDefaults *defaults;

@end

@implementation DataLoader

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (NSArray *)loadServices
{
    NSData *data = [self.defaults objectForKey:@"services"];
    
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if(!array) {
        array = [NSArray array];
    }
    
    return array;
}

- (void)saveServices:(NSArray *)services
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:services];
    
    [self.defaults setObject:data forKey:@"services"];
    
    [self.defaults synchronize];
}

@end
