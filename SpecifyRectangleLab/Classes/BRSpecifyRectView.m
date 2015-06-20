//
//  BRSpecifyRectView.m
//  SpecifyRectangleLab
//
//  Created by Kenji TAMAKI on 6/20/15.
//  Copyright (c) 2015 Brother Industries, Ltd. All rights reserved.
//

#import "BRSpecifyRectView.h"

@interface BRSpecifyRectView ()
@property (nonatomic, assign) NSPoint   startPoint;
@property (nonatomic, assign) NSPoint   endPoint;
@end

@implementation BRSpecifyRectView

#pragma mark - init/terminate

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.rectangle  = NSZeroRect;
        self.lineWidth  = 1.0;
        
        self.startPoint = NSZeroPoint;
        self.endPoint   = NSZeroPoint;
        
//        self.alphaValue = 0.5f;
    }
    return self;
}

#pragma mark - mouse event

- (void)mouseDown:(NSEvent *)theEvent
{
    self.startPoint = [self convertPoint:theEvent.locationInWindow fromView:[[self window] contentView]];
    self.endPoint = self.startPoint;
    
    [self setNeedsDisplay:YES];
    
    NSLog(@"mouseDown: %@, %@", [NSValue valueWithPoint:self.startPoint], [NSValue valueWithPoint:self.endPoint]);
}

- (void)mouseUp:(NSEvent *)theEvent
{
    self.endPoint = [self convertPoint:theEvent.locationInWindow fromView:[[self window] contentView]];
    
    [self setNeedsDisplay:YES];
    
    NSLog(@"mouseUp: %@, %@", [NSValue valueWithPoint:self.startPoint], [NSValue valueWithPoint:self.endPoint]);
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    self.endPoint = [self convertPoint:theEvent.locationInWindow fromView:[[self window] contentView]];
    
    [self setNeedsDisplay:YES];
    
    NSLog(@"mouseDragged: %@, %@", [NSValue valueWithPoint:self.startPoint], [NSValue valueWithPoint:self.endPoint]);
}

#pragma mark - draw

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    self.rectangle = [self rectFromPoint:self.startPoint point:self.endPoint];
    
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
