//
//  BRSpecifyRectAreaView.m
//  SpecifyRectangleLab
//
//  Created by Kenji TAMAKI on 6/20/15.
//  Copyright (c) 2015 Brother Industries, Ltd. All rights reserved.
//

#import "BRSpecifyRectAreaView.h"

// binding key
NSString * const kBRSpecifyRectViewBindingRectangle = @"rectangle";

// knob type
typedef NS_ENUM(NSInteger, BRKnobType) {
    kBRKnobTypeTopLeft,
    kBRKnobTypeTopRight,
    kBRKnobTypeButtomLeft,
    kBRKnobTypeButtomRight,
    kBRKnobTypeTop,
    kBRKnobTypeBottom,
    kBRKnobTypeLeft,
    kBRKnobTypeRight,
    kBRKnobTypeNone,
};

// resize rule
typedef struct {
    CGFloat x, y, w, h;
} BRResizeRule;

static const BRResizeRule rules[8] = {
    {1,  1, -1, -1}, // Top Left
    {0,  1,  1, -1}, // Top RIGHT
    {1,  0, -1,  1}, // Bottom Left
    {0,  0,  1,  1}, // Bottom Right
    {0,  1,  0, -1}, // Top
    {0,  0,  0,  1}, // Bottom
    {1,  0, -1,  0}, // Left
    {0,  0,  1,  0}, // Right
};


@interface BRSpecifyRectAreaView ()
@property (nonatomic, strong) NSTrackingArea *  trackingArea;
@property (nonatomic, assign) BOOL  mouseEntered;
@end


@implementation BRSpecifyRectAreaView

#pragma mark - init/terminate

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth          = 1.0;
        self.lineColors         = [NSArray arrayWithObjects:[NSColor colorWithDeviceWhite:0.0 alpha:0.6], [NSColor colorWithDeviceWhite:1.0 alpha:0.6], nil];
        self.lineDash           = 3.0;
        
        self.knobWidthInside    = 10.0;
        self.knobWidthOutside   = 10.0;
        
        self.keepRectangleInsideView = YES;
        self.specifyWholeAreaIfDoubleClicked = NO;
        
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
    
    [self discardCursorRects];
    
#if !__has_feature(objc_arc)
    self.lineColors = nil;
    self.trackingArea = nil;
    [super dealloc];
#endif
}

#pragma mark - coordinate

- (BOOL)isFlipped
{
    return YES;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil) {
        if ([keyPath isEqualToString:kBRSpecifyRectViewBindingRectangle]) {
            [self updateTrackingAreas];
            
            [self resetCursorRects];
            
            [self setNeedsDisplay:YES];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - mouse event

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:nil];
    BRKnobType knobType = [self knobTypeAtPoint:point];
    
    if (NSPointInRect(point, self.rectangle) && (theEvent.modifierFlags & NSCommandKeyMask)) {
        // change mouse cursor
        [[NSCursor openHandCursor] set];
        
        // move rectangle
        NSRect rect = self.rectangle;
        CGFloat dx = rect.origin.x - point.x;
        CGFloat dy = rect.origin.y - point.y;
        
        while (theEvent.type != NSLeftMouseUp) {
            theEvent = [self.window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
            point = [self convertPoint:theEvent.locationInWindow fromView:nil];
            rect.origin.x = point.x + dx;
            rect.origin.y = point.y + dy;
            
            if (self.keepRectangleInsideView) {
                self.rectangle = [self keptRectInView:rect];
            }
            else {
                self.rectangle = rect;
            }
            
            NSLog(@"mouseDown: %@", [NSValue valueWithRect:self.rectangle]);
        }
    }
    else if (knobType == kBRKnobTypeNone) {
        // create rectangle
        NSPoint startPoint  = point;
        NSPoint endPoint;
        
        while (theEvent.type != NSLeftMouseUp) {
            theEvent = [self.window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
            endPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
            
            NSRect rect = [self rectFromPoint:startPoint point:endPoint];
            if (self.keepRectangleInsideView) {
                self.rectangle = NSIntersectionRect(rect, self.bounds);
            }
            else {
                self.rectangle = rect;
            }
            
            NSLog(@"mouseDown: %@", [NSValue valueWithRect:self.rectangle]);
        }
        
        if (self.specifyWholeAreaIfDoubleClicked && (theEvent.type == NSLeftMouseUp) && (theEvent.clickCount == 2)) {
            self.rectangle = self.bounds;
        }
    }
    else {
        // expansion/reduction rectangle
        NSRect rect = self.rectangle;
        NSPoint prePoint;
        CGFloat dx, dy;
        
        while (theEvent.type != NSLeftMouseUp) {
            prePoint = point;
            theEvent = [self.window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
            point = [self convertPoint:theEvent.locationInWindow fromView:nil];
            dx = point.x - prePoint.x;
            dy = point.y - prePoint.y;
            
            BRResizeRule rule = rules[knobType];
            
            rect.origin.x       += dx * rule.x;
            rect.origin.y       += dy * rule.y;
            rect.size.width     += dx * rule.w;
            rect.size.height    += dy * rule.h;
            
            if (self.keepRectangleInsideView) {
                self.rectangle = NSIntersectionRect([self normalizedRect:rect], self.bounds);
            }
            else {
                self.rectangle = [self normalizedRect:rect];
            }
            
            NSLog(@"mouseDown: %@", [NSValue valueWithRect:self.rectangle]);
        }
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
    NSTrackingArea * trackingArea = [[NSTrackingArea alloc] initWithRect:self.rectangle
                                                                 options:options
                                                                   owner:self
                                                                userInfo:nil];
#if !__has_feature(objc_arc)
    [trackingArea autorelease];
#endif
    [self addTrackingArea:trackingArea];
    self.trackingArea = trackingArea;
    
    [super updateTrackingAreas];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

#pragma mark - knob

- (BRKnobType)knobTypeAtPoint:(NSPoint)point
{
    NSRect rect = self.rectangle;
    if      (NSPointInRect(point, [self topLeftKnobRect:rect]))     { return kBRKnobTypeTopLeft;        }
    else if (NSPointInRect(point, [self topRightKnobRect:rect]))    { return kBRKnobTypeTopRight;       }
    else if (NSPointInRect(point, [self bottomLeftKnobRect:rect]))  { return kBRKnobTypeButtomLeft;     }
    else if (NSPointInRect(point, [self bottomRightKnobRect:rect])) { return kBRKnobTypeButtomRight;    }
    else if (NSPointInRect(point, [self topKnobRect:rect]))         { return kBRKnobTypeTop;            }
    else if (NSPointInRect(point, [self bottomKnobRect:rect]))      { return kBRKnobTypeBottom;         }
    else if (NSPointInRect(point, [self leftKnobRect:rect]))        { return kBRKnobTypeLeft;           }
    else if (NSPointInRect(point, [self rightKnobRect:rect]))       { return kBRKnobTypeRight;          }
    else                                                            { return kBRKnobTypeNone;           }
}

#pragma mark - cursor

- (void)resetCursorRects
{
    [self discardCursorRects];
    [self addCursors];
}

- (void)addCursors
{
    NSRect rect = self.rectangle;
    if (! NSEqualSizes(rect.size, NSZeroSize)) {
        [self addCursorRect:[self topKnobRect:rect] cursor:[NSCursor resizeUpDownCursor]];
        [self addCursorRect:[self bottomKnobRect:rect] cursor:[NSCursor resizeUpDownCursor]];
        [self addCursorRect:[self leftKnobRect:rect] cursor:[NSCursor resizeLeftRightCursor]];
        [self addCursorRect:[self rightKnobRect:rect] cursor:[NSCursor resizeLeftRightCursor]];
        [self addCursorRect:[self topLeftKnobRect:rect] cursor:[NSCursor crosshairCursor]];
        [self addCursorRect:[self topRightKnobRect:rect] cursor:[NSCursor crosshairCursor]];
        [self addCursorRect:[self bottomLeftKnobRect:rect] cursor:[NSCursor crosshairCursor]];
        [self addCursorRect:[self bottomRightKnobRect:rect] cursor:[NSCursor crosshairCursor]];
    }
}

#pragma mark - cursor sub

- (NSRect)knobRectAtPoint:(NSPoint)point
{
    CGFloat knobWidth = self.knobWidthInside + self.knobWidthOutside;
    return NSMakeRect(point.x - self.knobWidthOutside, point.y - self.knobWidthOutside, knobWidth, knobWidth);
}

- (NSRect)topLeftKnobRect:(NSRect)frame
{
    return [self knobRectAtPoint:NSMakePoint(NSMinX(frame), NSMinY(frame))];
}

- (NSRect)topRightKnobRect:(NSRect)frame
{
    return [self knobRectAtPoint:NSMakePoint(NSMaxX(frame), NSMinY(frame))];
}

- (NSRect)bottomLeftKnobRect:(NSRect)frame
{
    return [self knobRectAtPoint:NSMakePoint(NSMinX(frame), NSMaxY(frame))];
}

- (NSRect)bottomRightKnobRect:(NSRect)frame
{
    return [self knobRectAtPoint:NSMakePoint(NSMaxX(frame), NSMaxY(frame))];
}

- (NSRect)topKnobRect:(NSRect)frame
{
    NSRect topLeftKnobRect = [self topLeftKnobRect:frame];
    NSRect topRightKnobRect = [self topRightKnobRect:frame];
    return NSMakeRect(NSMaxX(topLeftKnobRect), NSMinY(topLeftKnobRect), NSMinX(topRightKnobRect) - NSMaxX(topLeftKnobRect), NSHeight(topLeftKnobRect));
}

- (NSRect)bottomKnobRect:(NSRect)frame
{
    NSRect bottomLeftKnobRect = [self bottomLeftKnobRect:frame];
    NSRect bottomRightKnobRect = [self bottomRightKnobRect:frame];
    return NSMakeRect(NSMaxX(bottomLeftKnobRect), NSMinY(bottomLeftKnobRect), NSMinX(bottomRightKnobRect) - NSMaxX(bottomLeftKnobRect), NSHeight(bottomLeftKnobRect));
}

- (NSRect)leftKnobRect:(NSRect)frame
{
    NSRect topLeftKnobRect = [self topLeftKnobRect:frame];
    NSRect bottomLeftKnobRect = [self bottomLeftKnobRect:frame];
    return NSMakeRect(NSMinX(topLeftKnobRect), NSMaxY(topLeftKnobRect), NSWidth(topLeftKnobRect), NSMinY(bottomLeftKnobRect) - NSMaxY(topLeftKnobRect));
}

- (NSRect)rightKnobRect:(NSRect)frame
{
    NSRect topRightKnobRect = [self topRightKnobRect:frame];
    NSRect bottomRightKnobRect = [self bottomRightKnobRect:frame];
    return NSMakeRect(NSMinX(topRightKnobRect), NSMaxY(topRightKnobRect), NSWidth(topRightKnobRect), NSMinY(bottomRightKnobRect) - NSMaxY(topRightKnobRect));
}

#pragma mark - draw

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSGraphicsContext * ctx = [NSGraphicsContext currentContext];
    [ctx saveGraphicsState];
    [ctx setShouldAntialias:NO];
    
    NSBezierPath * bezierPath = [NSBezierPath bezierPath];
    NSRect rect = self.rectangle;
    if (self.keepRectangleInsideView) {
        rect.origin.y       += 1.0;
        rect.size.width     -= 1.0;
        rect.size.height    -= 1.0;
    }
    [bezierPath appendBezierPathWithRect:rect];
    [bezierPath setLineWidth:self.lineWidth];
    
    NSUInteger count = self.lineColors.count;
    CGFloat * lineDash = (CGFloat *)malloc(sizeof(CGFloat) * count);
    if (lineDash) {
        // set the line dash pattern
        for (NSUInteger idx = 0; idx < count; idx++) {
            lineDash[idx] = self.lineDash;
        }
        
        // draw line
        CGFloat phase = 0.0;
        for (NSUInteger idx = 0; idx < count; idx++) {
            NSColor * color = self.lineColors[idx];
            
            [color set];
            [bezierPath setLineDash:lineDash count:count phase:phase];
            [bezierPath stroke];
            
            phase += lineDash[idx];
        }
        
        free(lineDash);
    }
    
    [ctx restoreGraphicsState];
}

#pragma mark - rectangle

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

- (NSRect)normalizedRect:(NSRect)rect
{
    NSRect newRect = rect;
    
    if (rect.size.width < 0) {
        newRect.origin.x = rect.origin.x + rect.size.width;
        newRect.size.width = -rect.size.width;
    }
    if (rect.size.height < 0) {
        newRect.origin.y = rect.origin.y + rect.size.height;
        newRect.size.height = -rect.size.height;
    }
    
    return newRect;
}

- (NSRect)keptRectInView:(NSRect)rect
{
    NSRect newRect = [self normalizedRect:rect];
    CGFloat dx, dy;
    
    dx = NSMinX(newRect) - NSMinX(self.bounds);
    if (dx < 0) {
        newRect = NSOffsetRect(newRect, -dx, 0.0);
    }
    dx = NSMaxX(newRect) - NSMaxX(self.bounds);
    if (dx > 0) {
        newRect = NSOffsetRect(newRect, -dx, 0.0);
    }
    dy = NSMinY(newRect) - NSMinY(self.bounds);
    if (dy < 0) {
        newRect = NSOffsetRect(newRect, 0.0, -dy);
    }
    dy = NSMaxY(newRect) - NSMaxY(self.bounds);
    if (dy > 0) {
        newRect = NSOffsetRect(newRect, 0.0, -dy);
    }
    
    return newRect;
}

@end
