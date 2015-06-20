//
//  BRCustomView.m
//  CustomViewLab
//
//  Created by Kenji TAMAKI on 6/23/14.
//  Copyright (c) 2014 Brother Industries, Ltd. All rights reserved.
//

#import "BRCustomView.h"

NSString * const kBRCustomViewMouseDidClickNotification = @"kBRCustomViewMouseDidClickNotification";
NSString * const kBRCustomViewMouseDidEnterNotification = @"kBRCustomViewMouseDidEnterNotification";
NSString * const kBRCustomViewMouseDidExitNotification  = @"kBRCustomViewMouseDidExitNotification";

@interface BRCustomView ()
@property (nonatomic, strong) NSTrackingArea *  trackingArea;
@property (nonatomic, assign) BOOL  mousePressed;
@property (nonatomic, assign) BOOL  mouseEntered;
@end

@implementation BRCustomView

#pragma mark - Mouse Evet

- (void)mouseDown:(NSEvent *)theEvent
{
    if (self.mouseEvent) {
        self.mousePressed = YES;
        self.mouseEntered = YES;
        [self setNeedsDisplay:YES];
    }
    else {
        [super mouseDown:theEvent];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (self.mouseEvent) {
        if (self.mousePressed && self.mouseEntered) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kBRCustomViewMouseDidClickNotification object:self userInfo:nil];
        }
        self.mousePressed = NO;
        self.mouseEntered = NO;
        [self setNeedsDisplay:YES];
    }
    else {
        [super mouseUp:theEvent];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    if (self.mouseEvent) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBRCustomViewMouseDidEnterNotification object:self userInfo:nil];
        self.mouseEntered = YES;
        [self setNeedsDisplay:YES];
    }
    else {
        [super mouseEntered:theEvent];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    if (self.mouseEvent) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBRCustomViewMouseDidExitNotification object:self userInfo:nil];
        self.mouseEntered = NO;
        [self setNeedsDisplay:YES];
    }
    else {
        [super mouseExited:theEvent];
    }
}

#pragma mark - Mouse Evet Switch

- (void)updateTrackingAreas
{
    if (self.trackingArea) {
        [self removeTrackingArea:self.trackingArea];
    }
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                     options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow | NSTrackingEnabledDuringMouseDrag)
                                                       owner:self
                                                    userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)setMouseEvent:(BOOL)mouseEvent
{
    _mouseEvent = mouseEvent;
    
    self.mousePressed = NO;
    self.mouseEntered = NO;
    
    if (mouseEvent) {
        [self updateTrackingAreas];
    }
    else {
        if (self.trackingArea) {
            [self removeTrackingArea:self.trackingArea];
        }
    }
}

#pragma mark - Draw

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSGraphicsContext * ctx = [NSGraphicsContext currentContext];
    NSBezierPath * bezierPath;
    
    // border
    if (self.borderWidth) {
        [ctx saveGraphicsState];
        if (self.backgroundColor || self.backgroundGradient) {
            bezierPath = [self bezierPathWithFrame:self.bounds cornerRadius:self.cornerRadius];
            [self.borderColor setFill];
            [bezierPath fill];
        }
        else {
            bezierPath = [self bezierPathWithFrame:NSInsetRect(self.bounds, self.borderWidth / 2, self.borderWidth / 2) cornerRadius:self.cornerRadius];
            [self.borderColor setStroke];
            [bezierPath setLineWidth:self.borderWidth];
            [bezierPath stroke];
        }
        [ctx restoreGraphicsState];
    }
    
    // backbround color
    if (self.backgroundColor) {
        [ctx saveGraphicsState];
        bezierPath = [self bezierPathWithFrame:NSInsetRect(self.bounds, self.borderWidth, self.borderWidth) cornerRadius:self.cornerRadius];
        [self.backgroundColor setFill];
        [bezierPath fill];
        [ctx restoreGraphicsState];
    }
    
    // background gradient
    if (self.backgroundGradient) {
        [ctx saveGraphicsState];
        bezierPath = [self bezierPathWithFrame:NSInsetRect(self.bounds, self.borderWidth, self.borderWidth) cornerRadius:self.cornerRadius];
        [self.backgroundGradient drawInBezierPath:bezierPath angle:self.backgroundGradientAngle];
        [ctx restoreGraphicsState];
    }
    
    // background image
    if (self.backgroundImage) {
        [ctx saveGraphicsState];
        NSRect backgroundRect = NSInsetRect(self.bounds, self.backgroundImagePaddingX, self.backgroundImagePaddingY);
        [self.backgroundImage drawInRect:backgroundRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO hints:nil];
        [ctx restoreGraphicsState];
    }
    
    // highlight
    if (self.mouseDownHighlight && self.mousePressed && self.mouseEntered) {
        [ctx saveGraphicsState];
        NSBezierPath * bezierPath = [self bezierPathWithFrame:self.bounds cornerRadius:self.cornerRadius];
        [bezierPath addClip];
        [[NSColor colorWithCalibratedWhite:0.0f alpha:0.35] setFill];
        NSRectFillUsingOperation(self.bounds, NSCompositeSourceOver);
        [ctx restoreGraphicsState];
    }
}

#pragma mark - Draw Sub

- (NSBezierPath *)bezierPathWithFrame:(NSRect)frame cornerRadius:(CGFloat)cornerRadius
{
    if (cornerRadius) {
        return [NSBezierPath bezierPathWithRoundedRect:frame xRadius:cornerRadius yRadius:cornerRadius];
    }
    else {
        return [NSBezierPath bezierPathWithRect:frame];
    }
}

#pragma mark - Init

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.borderWidth = 0.0;
        self.backgroundGradientAngle = 0.0;
        self.backgroundImagePaddingX = 0.0;
        self.backgroundImagePaddingY = 0.0;
        self.cornerRadius = 0.0;
        
        self.mouseEvent = NO;
        self.mouseDownHighlight = NO;
        self.mousePressed = NO;
        self.mouseEntered = NO;
        [self updateTrackingAreas];
    }
    return self;
}

@end
