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

        // Initialize the application

    
        // Make sure the view matches the selected options
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
    [_showColourMapCheck setEnabled:_showSurfaceCheck.state==NSOnState];

    [_sceneView setOptionsWithBedOn:_showBedCheck.state==NSOnState
                           towersOn:_showTowersCheck.state==NSOnState
                            fakesOn:!_hideDummyPointsCheck.state==NSOnState
                           pointsOn:_showPointCheck.state==NSOnState
                      pointLabelsOn:_showPointLabelsCheck.state==NSOnState
                            linesOn:_showPointBarsCheck.state==NSOnState
                             gridOn:_showGridCheck.state==NSOnState
                          surfaceOn:_showSurfaceCheck.state==NSOnState
                        colourMapOn:_showColourMapCheck.state==NSOnState
                        wireFrameOn:_showWireFrameCheck.state==NSOnState];

    [_sceneView updateUI];
}

- (IBAction)updateG29Data:(NSButton *)sender {
    [self sendG29Data];
}

- (IBAction)populateDummyData:(id)sender {


    NSString *dummy1 = @"-0.088 -0.088 -0.088 -0.125 -0.150 -0.150 -0.150";
    NSString *dummy2 = @"-0.013 -0.013 -0.025 -0.037 -0.050 -0.087 -0.087";
    NSString *dummy3 = @"-0.050 0.012 0.037 0.050 -0.013 -0.000 0.112";
    NSString *dummy4 = @"-0.187 -0.100 -0.037 0.013 0.063 0.113 0.200";
    NSString *dummy5 = @"-0.200 -0.162 -0.050 0.000 0.000 0.088 0.288";
    NSString *dummy6 = @"-0.287 -0.287 -0.187 -0.087 0.000 0.138 0.138";
    NSString *dummy7 = @"0.225 0.225 0.225 -0.112 0.025 0.025 0.025";

     NSArray *dummyArray = [[NSArray alloc] initWithObjects:dummy1, dummy2, dummy3, dummy4, dummy5, dummy6, dummy7, nil];
     NSString *dummy = [dummyArray componentsJoinedByString:@"\n"];

    [_G29Data setStringValue:dummy];
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


- (IBAction)loadPlotData:(id)sender
{
        // get the url of a probe data file
    NSOpenPanel * openPanel = [NSOpenPanel openPanel];

    NSArray * arrayOfExtensions = [NSArray arrayWithObject:@"probe"];
    [openPanel setAllowedFileTypes:arrayOfExtensions];

    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];

    NSInteger result = [openPanel runModal];

    if (result == NSFileHandlingPanelCancelButton) {
        return;
    }

    NSURL *url = [openPanel URL];

        // read the probe data from the file
    NSString * plotData = [NSString stringWithContentsOfURL:url
                                               encoding:NSASCIIStringEncoding
                                                  error:NULL];
    [_G29Data setStringValue:plotData];
    [self sendG29Data];
}

- (IBAction)savePlotData:(id)sender
{
        // get the file url
    NSSavePanel * savePanel = [NSSavePanel savePanel];

    NSArray * arrayOfExtensions = [NSArray arrayWithObject:@"probe"];
    [savePanel setAllowedFileTypes:arrayOfExtensions];

    [savePanel setCanCreateDirectories:YES];

    NSInteger result = [savePanel runModal];
    if (result == NSFileHandlingPanelCancelButton) {
        return;
    }

    NSURL *url = [savePanel URL];

        //write the probe data to the file
    BOOL boolResult = [[_G29Data stringValue] writeToURL:url
                                              atomically:YES
                                                encoding:NSASCIIStringEncoding
                                                   error:NULL];
    if (! boolResult) {
        [[NSAlert alertWithMessageText:@"Failed to save"
                         defaultButton:@"Ok"
                       alternateButton:nil
                           otherButton:nil
             informativeTextWithFormat:@"Something went wrong saving your plot data"] runModal];
    }
}


@end
