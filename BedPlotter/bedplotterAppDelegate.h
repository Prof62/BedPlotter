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
- (IBAction)showPoints:(NSButton *)sender;

@property (weak) IBOutlet NSButton *showPointCheck;
@property (weak) IBOutlet NSTextField *G29Data;

@property (strong, nonatomic) IBOutlet MJDSceneView *sceneView;

- (void)homeCamera:(id)sender;
- (void)updateUI:(id)sender;

@end
