//
//  TextEntryTableView.m
//  Bonjour Broadcaster
//
//  Created by Adam Gastineau on 9/6/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "TextEntryTableView.h"

#import "TextEntryRowView.h"

@interface TextEntryTableView ()

@property (nonatomic) NSInteger rowCount;

@end

@implementation TextEntryTableView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setDelegate:self];
        [self setDataSource:self];
    };
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDelegate:self];
        [self setDataSource:self];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSArray *)enteredText
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    for(int i = 0; i < self.rowCount; i++) {
        TextEntryRowView *view = [self viewAtColumn:0 row:i makeIfNecessary:NO];
        
        if(view) {
            NSString *string = [[view.textfield stringValue] stringByTrimmingCharactersInSet:set];
            
            if(![string isEqualToString:@""]) {
                [array addObject:string];
            }
        }
    }
    
    return [NSArray arrayWithArray:array];
}

- (void)addNewRowAfterRow:(NSView *)rowView
{
    NSInteger rowIndex = [self rowForView:rowView];
    
    if(rowIndex == -1) {
        return;
    }
    
    if(self.rowCount == 1) {
        TextEntryRowView *view = [self viewAtColumn:0 row:0 makeIfNecessary:NO];
        
        if(view) {
            [view.removeButton setHidden:NO];
        }
    }
    
    self.rowCount++;
    
    [self insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:rowIndex+1] withAnimation:NSTableViewAnimationEffectFade];
    
    [self updateHeight];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSRect rowRect = [self rectOfRow:rowIndex+1];
        NSRect viewRect = [[self superview] frame];
        NSPoint scrollOrigin = rowRect.origin;
        scrollOrigin.y = scrollOrigin.y + (rowRect.size.height - viewRect.size.height) / 2;
        if (scrollOrigin.y < 0) scrollOrigin.y = 0;
        [[[self superview] animator] setBoundsOrigin:scrollOrigin];
        
        TextEntryRowView *view = [self viewAtColumn:0 row:rowIndex+1 makeIfNecessary:YES];
        [view.textfield becomeFirstResponder];        
    }];
}

- (void)removeRow:(NSView *)rowView
{
    NSInteger rowIndex = [self rowForView:rowView];
    
    if(rowIndex == -1) {
        return;
    }

    self.rowCount--;
    
    [self removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:rowIndex] withAnimation:NSTableViewAnimationEffectFade];
    
    if(self.rowCount == 1) {
        TextEntryRowView *view = [self viewAtColumn:0 row:0 makeIfNecessary:NO];
        
        if(view) {
            [view.removeButton setHidden:YES];
        }
    }
    
    [self updateHeight];
}

- (void)updateHeight
{
    // 32 is the height of each row
    [self.heightConstraint setConstant:32 * self.rowCount];
}

- (void)setRowStrings:(NSArray *)rowStrings
{
    _rowStrings = rowStrings;
    
    self.rowCount = [rowStrings count];
}

#pragma mark - NSTableViewDelegate/DataSource Methods

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    TextEntryRowView *view = [self makeViewWithIdentifier:@"textEntryRow" owner:self];
    
    if(!view) {
        view = [[TextEntryRowView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
    }
    
    [view setTableView:self];
    [view setRow:row];
    
    if(row < [self.rowStrings count]) {
        NSString *rowString = [self.rowStrings objectAtIndex:row];
        
        [view.textfield setStringValue:rowString];
    } else {
        [view.textfield setStringValue:@""];
    }
    
    if(row == 0 && [self numberOfRowsInTableView:self] == 1) {
        [view.removeButton setHidden:YES];
    } else {
        [view.removeButton setHidden:NO];
    }
    
    [self updateHeight];
    
    return view;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if(self.rowCount < 1) {
        self.rowCount = 1;
    }
    
    return self.rowCount;
}

@end
