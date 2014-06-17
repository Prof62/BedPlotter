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

        // Initialize your application

    [self sendOptions ];

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
    [self sendG29Data];
}


- (IBAction)checkChanged:(NSButton *)sender;
{
    [self sendOptions ];
}

-(void)sendOptions
{
    [_showPointLabelsCheck setEnabled:_showPointCheck.state==NSOnState];
    [_sceneView setOptionsWithBedOn:_showBedCheck.state==NSOnState
                           towersOn:_showTowersCheck.state==NSOnState
                            fakesOn:!_hideDummyPointsCheck.state==NSOnState
                           pointsOn:_showPointCheck.state==NSOnState
                      pointLabelsOn:_showPointLabelsCheck.state==NSOnState
                            linesOn:_showPointBarsCheck.state==NSOnState
                             gridOn:_showGridCheck.state==NSOnState
                            planeOn:_showSurfaceCheck.state==NSOnState
                        wireFrameOn:_showWireFrameCheck.state==NSOnState];
    [_sceneView updateUI];
}

- (IBAction)updateG29Data:(NSButton *)sender {
    [self sendG29Data];
}

-(void)sendG29Data
{
    if ( [_G29Data.stringValue length] > 0 )
         {

         [_sceneView setPoints: _G29Data.stringValue];
         [_sceneView updateUI];
         }
         }
         
         @end
