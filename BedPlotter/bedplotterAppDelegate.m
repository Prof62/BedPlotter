//
//  bedplotterAppDelegate.m
//  BedPlotter
//
//  Created by Mark Dunsford on 07/06/2014.
//  Copyright (c) 2014 Mark Dunsford. All rights reserved.
//

#import "bedplotterAppDelegate.h"

@implementation bedplotterAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    NSScreen *screen = [[NSScreen screens] firstObject];
    NSRect screenRect = [screen frame];
    NSWindow *window = [[NSWindow alloc] initWithContentRect:screenRect
                                                   styleMask:NSBorderlessWindowMask
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO
                                                      screen:screen];
    [window setLevel: CGShieldingWindowLevel()];

    // Insert code here to initialize your application

}

- (void)updateUI:(id)sender
{
    [_sceneView updateUI];
}

- (IBAction)homeCamera:(id)sender
{
    [_sceneView homeCamera];
}

- (IBAction)GD29DataChanged:(NSTextField *)sender {
    
}

- (IBAction)showPoints:(NSButton *)sender {
}
@end
