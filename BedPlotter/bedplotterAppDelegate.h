//
//  bedplotterAppDelegate.h
//  BedPlotter
//
//  Created by Mark Dunsford on 07/06/2014.
//  Copyright (c) 2014 Mark Dunsford. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MJDSceneView.h"

@interface bedplotterAppDelegate : NSObject <NSApplicationDelegate>

- (IBAction)GD29DataChanged:(NSTextField *)sender;
- (IBAction)checkChanged:(NSButton *)sender;
- (IBAction)updateG29Data:(NSButton *)sender;

@property (weak) IBOutlet NSButton *showBedCheck;
@property (weak) IBOutlet NSButton *showTowersCheck;
@property (weak) IBOutlet NSButton *showSurfaceCheck;
@property (weak) IBOutlet NSButton *showGridCheck;
@property (weak) IBOutlet NSButton *showWireFrameCheck;
@property (weak) IBOutlet NSButton *showPointCheck;
@property (weak) IBOutlet NSButton *showPointBarsCheck;
@property (weak) IBOutlet NSButton *showPointLabelsCheck;
@property (weak) IBOutlet NSButton *hideDummyPointsCheck;

@property (weak) IBOutlet NSTextField *G29Data;

@property (strong, nonatomic) IBOutlet MJDSceneView *sceneView;

- (void)homeCamera:(id)sender;
- (void)updateUI:(id)sender;

@end
