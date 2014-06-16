//
//  MJDSceneView.h
//  BedPlotter
//
//  Created by Mark Dunsford on 14/06/2014.
//  Copyright (c) 2014 Mark Dunsford. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

@interface MJDSceneView : SCNView

-(void)homeCamera;
-(void)updateUI;
-(void)setOptionsWithBedOn:(Boolean) mShowBed
                  towersOn:(Boolean) mShowTowers
                   fakesOn:(Boolean) mShowFakes
                  pointsOn:(Boolean) mShowPoints
             pointLabelsOn:(Boolean) mShowPointLabels
                   linesOn:(Boolean) mShowLines
                    gridOn:(Boolean) mShowGrid
                   planeOn:(Boolean) mShowPlane;

-(void) setPoints:(NSString *) G29Data;

@end
