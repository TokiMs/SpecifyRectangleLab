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

static const CGFloat kKnobWidthInside   = 10.0;
static const CGFloat kKnobWidthOutside  = 10.0;
static const CGFloat kKnobWidth         = kKnobWidthInside + kKnobWidthOutside;

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
    
    [self discardCursorRects];
    
#if !__has_feature(objc_arc)
    self.trackingArea = nil;
    [self dealloc];
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
            
            self.rectangle = rect;
            
            NSLog(@"mouseDown: %@", [NSValue valueWithRect:self.rectangle]);
        }
    }
    else if (knobType == kBRKnobTypeNone) {
        // create rectangle
        NSPoint startPoint  = point;
        NSPoint endPoint    = point;
        
        while (theEvent.type != NSLeftMouseUp) {
            theEvent = [self.window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
            endPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
            
            self.rectangle = [self rectFromPoint:startPoint point:endPoint];
            
            NSLog(@"mouseDown: %@", [NSValue valueWithRect:self.rectangle]);
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
            
            self.rectangle = [self normalizedRect:rect];
            
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
    return NSMakeRect(point.x - kKnobWidthOutside, point.y - kKnobWidthOutside, kKnobWidth, kKnobWidth);
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

@end
