//
//  BRCustomView.h
//  CustomViewLab
//
//  Created by Kenji TAMAKI on 6/23/14.
//  Copyright (c) 2014 Brother Industries, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const kBRCustomViewMouseDidClickNotification;
extern NSString * const kBRCustomViewMouseDidEnterNotification;
extern NSString * const kBRCustomViewMouseDidExitNotification;

@interface BRCustomView : NSView

@property (nonatomic, assign) CGFloat       borderWidth;
@property (nonatomic, strong) NSColor *     borderColor;

@property (nonatomic, strong) NSColor *     backgroundColor;

@property (nonatomic, strong) NSGradient *  backgroundGradient;
@property (nonatomic, assign) CGFloat       backgroundGradientAngle;

@property (nonatomic, strong) NSImage *     backgroundImage;
@property (nonatomic, assign) CGFloat       backgroundImagePaddingX;
@property (nonatomic, assign) CGFloat       backgroundImagePaddingY;

@property (nonatomic, assign) CGFloat       cornerRadius;

// Mouse Event
@property (nonatomic, assign) BOOL          mouseEvent;
@property (nonatomic, assign) BOOL          mouseDownHighlight;

@end
