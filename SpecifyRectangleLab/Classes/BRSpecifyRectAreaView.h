//
//  BRSpecifyRectAreaView.h
//  SpecifyRectangleLab
//
//  Created by Kenji TAMAKI on 6/20/15.
//  Copyright (c) 2015 Brother Industries, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BRSpecifyRectAreaView : NSView

@property (nonatomic, assign) CGFloat   lineWidth;
@property (nonatomic, copy) NSArray *   lineColors;
@property (nonatomic, assign) CGFloat   lineDash;

@property (nonatomic, assign) CGFloat   knobWidthInside;
@property (nonatomic, assign) CGFloat   knobWidthOutside;

@property (nonatomic, assign) BOOL      keepAreaInsideView;
@property (nonatomic, assign) BOOL      specifyWholeBoundsIfDoubleClicked;

@property (nonatomic, assign) NSRect    areaRect;

@end
