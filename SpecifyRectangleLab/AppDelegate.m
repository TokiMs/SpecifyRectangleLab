//
//  AppDelegate.m
//  SpecifyRectangleLab
//
//  Created by Kenji TAMAKI on 6/20/15.
//  Copyright (c) 2015 Brother Industries, Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "BRCustomView.h"
#import "BRSpecifyRectAreaView.h"

@interface AppDelegate ()
@property (nonatomic, weak) IBOutlet NSWindow * window;
@property (nonatomic, weak) IBOutlet BRCustomView * originalImageView;
@property (nonatomic, weak) IBOutlet BRCustomView * croppedImageView;

@property (nonatomic, strong) BRSpecifyRectAreaView * specifyRectAreaView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    self.originalImageView.backgroundColor = [NSColor grayColor];
    self.croppedImageView.backgroundColor = [NSColor grayColor];
    
    self.originalImageView.backgroundImage = [NSImage imageNamed:@"Image.jpg"];
    
    NSSize size = self.originalImageView.frame.size;
    self.specifyRectAreaView = [[BRSpecifyRectAreaView alloc] initWithFrame:NSMakeRect(0.0, 0.0, size.width, size.height)];
    self.specifyRectAreaView.specifyWholeBoundsIfDoubleClicked = YES;
    [self.originalImageView addSubview:self.specifyRectAreaView];
    
    [self.window display];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    
}

@end
