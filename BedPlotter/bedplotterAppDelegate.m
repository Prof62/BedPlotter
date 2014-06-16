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

- (IBAction)GD29DataChanged:(NSTextField *)sender
{
    [_sceneView setPoints: _G29Data.stringValue];
    [_sceneView updateUI];
}


- (IBAction)checkChanged:(NSButton *)sender;
{
    [_sceneView setOptionsWithBedOn:_showBedCheck.state==NSOnState
                           towersOn:_showTowersCheck.state==NSOnState
                            fakesOn:!_hideDummyPointsCheck.state==NSOnState
                           pointsOn:_showPointCheck.state==NSOnState
                      pointLabelsOn:_showPointLabelsCheck.state==NSOnState
                            linesOn:_showPointBarsCheck.state==NSOnState
                             gridOn:_showGridCheck.state==NSOnState
                            planeOn:_showSurfaceCheck.state==NSOnState];
    [_sceneView updateUI];
}

- (IBAction)updateG29Data:(NSButton *)sender {
    [_sceneView setPoints: _G29Data.stringValue];
    [_sceneView updateUI];
}

@end
