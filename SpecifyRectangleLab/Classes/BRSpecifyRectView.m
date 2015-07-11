//
//  BRSpecifyRectView.m
//  SpecifyRectangleLab
//
//  Created by Kenji TAMAKI on 6/20/15.
//  Copyright (c) 2015 Brother Industries, Ltd. All rights reserved.
//

#import "BRSpecifyRectView.h"

// binding key
NSString * const kBRSpecifyRectViewBindingRectangle = @"rectangle";


@interface BRSpecifyRectView ()
@property (nonatomic, strong) NSTrackingArea *  trackingArea;
@property (nonatomic, assign) BOOL  mouseEntered;
@end


@implementation BRSpecifyRectView

#pragma mark - init/terminate

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth  = 1.0;
        
//        self.alphaValue = 0.5f;
        
        self.trackingArea   = nil;
        self.mouseEntered   = NO;
        
        // observe
        [self addObserver:self forKeyPath:kBRSpecifyRectViewBindingRectangle options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:kBRSpecifyRectViewBindingRectangle];
    
#if !__has_feature(objc_arc)
    [self dealloc];
#endif
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil) {
        if ([keyPath isEqualToString:kBRSpecifyRectViewBindingRectangle]) {
            [self updateTrackingAreas];
            
            [self setNeedsDisplay:YES];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - mouse event

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint startPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    NSPoint endPoint = startPoint;
    while (theEvent.type != NSLeftMouseUp) {
        theEvent = [self.window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        endPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
        
        self.rectangle = [self rectFromPoint:startPoint point:endPoint];
        
        NSLog(@"mouseDown: %@", [NSValue valueWithRect:self.rectangle]);
    }
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.mouseEntered = YES;
    
    [self setNeedsDisplay:YES];
    
    NSLog(@"mouseEntered:");
}

- (void)mouseExited:(NSEvent *)theEvent
{
    self.mouseEntered = NO;
    
    [self setNeedsDisplay:YES];
    
    NSLog(@"mouseExited:");
}

- (void)updateTrackingAreas
{
    // remove
    if (self.trackingArea) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    // add
    NSTrackingAreaOptions options = (NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow | NSTrackingEnabledDuringMouseDrag);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.rectangle
                                                     options:options
                                                       owner:self
                                                    userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

#pragma mark - draw

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
//    NSColor * color = [NSColor colorWithCalibratedWhite:1.0f alpha:0.3f];
//    NSColor * color = [NSColor colorWithDeviceRed:1.0f green:1.0f blue:1.0f alpha:0.5f];
    NSColor * color = [NSColor blackColor];
    [color set];
    
    NSBezierPath * bezierPath = [NSBezierPath bezierPath];
    // set the line dash pattern
    CGFloat lineDash[2];
    lineDash[0] = 10.0;
    lineDash[1] = 5.0;
    [bezierPath setLineDash:lineDash count:2 phase:0.0];
    //
    [bezierPath appendBezierPathWithRect:self.rectangle];
    [bezierPath setLineWidth:self.lineWidth];
    [bezierPath stroke];
//    [NSBezierPath strokeRect:self.rectangle];
//    NSRectFill(self.rectangle);
}

- (NSRect)rectFromPoint:(NSPoint)p1 point:(NSPoint)p2
{
    NSRect rect;
    NSPoint origin;
    NSSize size;
    
    origin.x    = p1.x < p2.x ? p1.x : p2.x;
    origin.y    = p1.y < p2.y ? p1.y : p2.y;
    size.width  = p1.x < p2.x ? p2.x - p1.x : p1.x - p2.x;
    size.height = p1.y < p2.y ? p2.y - p1.y : p1.y - p2.y;
    rect.origin = origin;
    rect.size   = size;
    
    return rect;
}

@end
