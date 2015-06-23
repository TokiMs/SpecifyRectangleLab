//
//  BRSpecifyRectView.m
//  SpecifyRectangleLab
//
//  Created by Kenji TAMAKI on 6/20/15.
//  Copyright (c) 2015 Brother Industries, Ltd. All rights reserved.
//

#import "BRSpecifyRectView.h"

// binding key
NSString * const kBRSpecifyRectViewBindingRectangle     = @"rectangle";
NSString * const kBRSpecifyRectViewBindingStartPoint    = @"startPoint";
NSString * const kBRSpecifyRectViewBindingEndPoint      = @"endPoint";

static const CGFloat kRectThickness = 3.0;


@interface BRSpecifyRectView ()
@property (nonatomic, assign) NSPoint   startPoint;
@property (nonatomic, assign) NSPoint   endPoint;
//
@property (nonatomic, strong) NSTrackingArea *  trackingArea;
@property (nonatomic, assign) BOOL  mousePressed;
@property (nonatomic, assign) BOOL  mouseEntered;
@end


@implementation BRSpecifyRectView

#pragma mark - init/terminate

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth  = 1.0;
        
        self.startPoint = NSZeroPoint;
        self.endPoint   = NSZeroPoint;
        
//        self.alphaValue = 0.5f;
        
        self.trackingArea   = nil;
        self.mousePressed   = NO;
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

#pragma mark - getter

- (NSRect)rectangle
{
    return [self rectFromPoint:self.startPoint point:self.endPoint];
}

#pragma mark - KVO

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet * keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    NSArray * affectingKeys;
    
    if ([key isEqualToString:kBRSpecifyRectViewBindingRectangle]) {
        affectingKeys = @[kBRSpecifyRectViewBindingStartPoint, kBRSpecifyRectViewBindingEndPoint];
    }
    
    return affectingKeys ? [keyPaths setByAddingObjectsFromArray:affectingKeys] : keyPaths;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil) {
        if ([keyPath isEqualToString:kBRSpecifyRectViewBindingRectangle]) {
            [self updateTrackingAreas];
            
            [self resetCursorRects];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - mouse event

- (void)mouseDown:(NSEvent *)theEvent
{
    self.mousePressed = YES;
    
    self.startPoint = [self convertPoint:theEvent.locationInWindow fromView:[[self window] contentView]];
    self.endPoint = self.startPoint;
    
    [self setNeedsDisplay:YES];
    
    NSLog(@"mouseDown: %@, %@", [NSValue valueWithPoint:self.startPoint], [NSValue valueWithPoint:self.endPoint]);
}

- (void)mouseUp:(NSEvent *)theEvent
{
    self.mousePressed = NO;
    
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
    if (self.mousePressed == NO) {
        NSTrackingAreaOptions options = (NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow | NSTrackingEnabledDuringMouseDrag);
        self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.rectangle
                                                         options:options
                                                           owner:self
                                                        userInfo:nil];
        [self addTrackingArea:self.trackingArea];
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
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
        [self addCursorRect:[self buttomKnobRect:rect] cursor:[NSCursor resizeUpDownCursor]];
        [self addCursorRect:[self leftKnobRect:rect] cursor:[NSCursor resizeLeftRightCursor]];
        [self addCursorRect:[self rightKnobRect:rect] cursor:[NSCursor resizeLeftRightCursor]];
        [self addCursorRect:[self topLeftKnobRect:rect] cursor:[NSCursor crosshairCursor]];
        [self addCursorRect:[self topRightKnobRect:rect] cursor:[NSCursor crosshairCursor]];
        [self addCursorRect:[self buttomLeftKnobRect:rect] cursor:[NSCursor crosshairCursor]];
        [self addCursorRect:[self buttomRightKnobRect:rect] cursor:[NSCursor crosshairCursor]];
    }
}

#pragma mark - cursor sub

- (NSRect)topLeftKnobRect:(NSRect)frame
{
    return NSMakeRect(NSMinX(frame) - kRectThickness / 2, NSMinY(frame) - kRectThickness / 2, kRectThickness, kRectThickness);
}

- (NSRect)topRightKnobRect:(NSRect)frame
{
    return NSMakeRect(NSMaxX(frame) - kRectThickness / 2, NSMinY(frame) - kRectThickness / 2, kRectThickness, kRectThickness);
}

- (NSRect)buttomLeftKnobRect:(NSRect)frame
{
    return NSMakeRect(NSMinX(frame) - kRectThickness / 2, NSMaxY(frame) - kRectThickness / 2, kRectThickness, kRectThickness);
}

- (NSRect)buttomRightKnobRect:(NSRect)frame
{
    return NSMakeRect(NSMaxX(frame) - kRectThickness / 2, NSMaxY(frame) - kRectThickness / 2, kRectThickness, kRectThickness);
}

- (NSRect)topKnobRect:(NSRect)frame
{
    NSRect topLeftKnobRect = [self topLeftKnobRect:frame];
    NSRect topRightKnobRect = [self topRightKnobRect:frame];
    return NSMakeRect(NSMaxX(topLeftKnobRect), NSMinY(topLeftKnobRect), NSMinX(topRightKnobRect) - NSMaxX(topLeftKnobRect), NSHeight(topLeftKnobRect));
}

- (NSRect)buttomKnobRect:(NSRect)frame
{
    NSRect buttomLeftKnobRect = [self buttomLeftKnobRect:frame];
    NSRect buttomRightKnobRect = [self buttomRightKnobRect:frame];
    return NSMakeRect(NSMaxX(buttomLeftKnobRect), NSMinY(buttomLeftKnobRect), NSMinX(buttomRightKnobRect) - NSMaxX(buttomLeftKnobRect), NSHeight(buttomLeftKnobRect));
}

- (NSRect)leftKnobRect:(NSRect)frame
{
    NSRect topLeftKnobRect = [self topLeftKnobRect:frame];
    NSRect buttomLeftKnobRect = [self buttomLeftKnobRect:frame];
    return NSMakeRect(NSMinX(topLeftKnobRect), NSMaxY(topLeftKnobRect), NSWidth(topLeftKnobRect), NSMinY(buttomLeftKnobRect) - NSMaxY(topLeftKnobRect));
}

- (NSRect)rightKnobRect:(NSRect)frame
{
    NSRect topRightKnobRect = [self topRightKnobRect:frame];
    NSRect buttomRightKnobRect = [self buttomRightKnobRect:frame];
    return NSMakeRect(NSMinX(topRightKnobRect), NSMaxY(topRightKnobRect), NSWidth(topRightKnobRect), NSMinY(buttomRightKnobRect) - NSMaxY(topRightKnobRect));
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
