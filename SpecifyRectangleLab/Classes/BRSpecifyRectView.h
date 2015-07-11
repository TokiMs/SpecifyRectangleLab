//
//  BRSpecifyRectView.h
//  SpecifyRectangleLab
//
//  Created by Kenji TAMAKI on 6/20/15.
//  Copyright (c) 2015 Brother Industries, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BRSpecifyRectView : NSView

@property (nonatomic, assign) CGFloat   lineWidth;
@property (nonatomic, assign) CGFloat   lineDash;
@property (nonatomic, assign) CGFloat   lineAlpha;
@property (nonatomic, assign) CGFloat   knobWidthInside;
@property (nonatomic, assign) CGFloat   knobWidthOutside;

@property (nonatomic, assign) BOOL      keepRectangleInsideView;
@property (nonatomic, assign) BOOL      specifyWholeAreaIfDoubleClicked;

@property (nonatomic, assign) NSRect    rectangle;

@end
