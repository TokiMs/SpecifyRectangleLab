//
//  AppDelegate.m
//  SpecifyRectangleLab
//
//  Created by Kenji TAMAKI on 6/20/15.
//  Copyright (c) 2015 Brother Industries, Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "BRCustomView.h"

@interface AppDelegate ()
@property (nonatomic, weak) IBOutlet NSWindow * window;
@property (nonatomic, weak) IBOutlet BRCustomView * originalImageView;
@property (nonatomic, weak) IBOutlet BRCustomView * croppedImageView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    self.originalImageView.backgroundColor = [NSColor grayColor];
    self.croppedImageView.backgroundColor = [NSColor grayColor];
    
    [self.window display];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    
}

@end
