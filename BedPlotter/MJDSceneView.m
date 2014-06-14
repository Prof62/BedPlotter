    //
    //  MJDSceneView.m
    //  BedPlotter
    //
    //  Created by Mark Dunsford on 14/06/2014.
    //  Copyright (c) 2014 Mark Dunsford. All rights reserved.
    //

#import "MJDSceneView.h"

@interface MJDSceneView ()

@property (strong, nonatomic) NSArray *points;

@end

@implementation MJDSceneView

SCNNode *cameraNode;


bool spin = false;
bool showTowers = true;
bool showPoints = true;
bool showPointLabels = true;
bool showLines = true;
bool showPlane = true;

float points[7][7] = {
    { -0.138, -0.138, -0.138, -0.200, -0.300, -0.300, -0.300 },
    { -0.050, -0.050, -0.075, -0.113, -0.113, -0.138, -0.138 },
    { -0.138, -0.063, -0.025, -0.050, -0.063, -0.075,  0.050 },
    { -0.225, -0.188, -0.088, -0.050, -0.000,  0.037,  0.162 },
    { -0.275, -0.188, -0.150, -0.088, -0.075,  0.062,  0.212 },
    { -0.325, -0.325, -0.263, -0.138, -0.088,  0.112,  0.112 },
    { 0.087,   0.087,  0.087, -0.238,  0.012,  0.012,  0.012 } };

-(void)homeCamera
{
    self.pointOfView = cameraNode;
}

-(void)awakeFromNib
{
        // Use a blue glass material for the bed
    SCNMaterial *bedMaterial = [SCNMaterial material];
    bedMaterial.diffuse.contents  = [NSColor blueColor];
    bedMaterial.specular.contents = [NSColor whiteColor];
    bedMaterial.shininess = 1.0;
    bedMaterial.transparency = 0.1;

        // Use a yellow glass material for the kapton
    SCNMaterial *kaptonMaterial = [SCNMaterial material];
    kaptonMaterial.diffuse.contents  = [NSColor yellowColor];
    kaptonMaterial.specular.contents = [NSColor whiteColor];
    kaptonMaterial.shininess = 1.0;
    kaptonMaterial.transparency = 0.3f;

        // Use a black glass material for the towers
    SCNMaterial *towerMaterial = [SCNMaterial material];
    towerMaterial.diffuse.contents  = [NSColor blackColor];
    towerMaterial.specular.contents = [NSColor whiteColor];
    towerMaterial.shininess = 1.0;
    towerMaterial.transparency = 0.04;

        // Use a dark grey glass material for the tower labels
    SCNMaterial *towerLabelMaterial = [SCNMaterial material];
    towerLabelMaterial.diffuse.contents  = [NSColor darkGrayColor];
    towerMaterial.specular.contents = [NSColor blackColor];
    towerLabelMaterial.shininess = 1.0;
    towerLabelMaterial.transparency = 1;



    self.backgroundColor = [NSColor grayColor];

        // Create an empty scene
        //SCNScene *scene = [SCNScene scene];
    SCNScene *scene = [SCNScene scene];
    self.scene = scene;

        // Create a camera
    SCNCamera *camera = [SCNCamera camera];
    camera.xFov = 45;   // Degrees, not radians
    camera.yFov = 45;
    cameraNode = [SCNNode node];
    cameraNode.camera = camera;
    cameraNode.position = SCNVector3Make(0, 8, 30);
    [scene.rootNode addChildNode:cameraNode];



        // Create ambient light
    SCNLight *ambientLight = [SCNLight light];
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLight.type = SCNLightTypeAmbient;
    ambientLight.color = [NSColor colorWithDeviceWhite:0.1 alpha:1.0];
    ambientLightNode.light = ambientLight;
    [scene.rootNode addChildNode:ambientLightNode];

        // Create the upper diffuse light
    SCNLight *diffuseLight = [SCNLight light];
    SCNNode *diffuseLightNode = [SCNNode node];
    diffuseLight.type = SCNLightTypeOmni;
    diffuseLightNode.light = diffuseLight;
    diffuseLightNode.position = SCNVector3Make(-30, 30, 50);
    [scene.rootNode addChildNode:diffuseLightNode];

        // Create the lower diffuse light
    SCNLight *diffuseLight2 = [SCNLight light];
    SCNNode *diffuseLight2Node = [SCNNode node];
    diffuseLight2.type = SCNLightTypeOmni;
    diffuseLight2Node.light = diffuseLight2;
    diffuseLight2.color = [NSColor colorWithDeviceWhite:0.4 alpha:1.0];
    diffuseLight2Node.position = SCNVector3Make(30, -30, 50);
    [scene.rootNode addChildNode:diffuseLight2Node];



        // Invisible world cube to force camera pivot to centre
    SCNBox *world = [SCNBox boxWithWidth:100 height:100 length:100 chamferRadius:0];
    SCNNode *worldNode = [SCNNode nodeWithGeometry:world];
    [scene.rootNode addChildNode:worldNode];

        // Create a disc for the reference bed
    SCNCylinder *bed = [SCNCylinder cylinderWithRadius:8.5 height:0.3];
    SCNNode *bedNode = [SCNNode nodeWithGeometry:bed];
    bed.materials = @[bedMaterial];
    [scene.rootNode addChildNode:bedNode];

        // Create a disc for the kapton film on the reference bed
    SCNCylinder *kapton = [SCNCylinder cylinderWithRadius:8.5 height:0.01];
    SCNNode *kaptonNode = [SCNNode nodeWithGeometry:kapton];
    kaptonNode.position = SCNVector3Make(0.f, 0.15f, 0.f);
    kapton.materials = @[kaptonMaterial];
    [bedNode addChildNode:kaptonNode];

    if(showTowers)
        {
            // Add the towers
        SCNBox *alphaTower = [SCNBox boxWithWidth:1.f height:60.f length:1.f chamferRadius:0.2];
        SCNNode *alphaTowerNode = [SCNNode nodeWithGeometry:alphaTower];
        alphaTowerNode.position = SCNVector3Make(sin(DegreesToRadians(300))*10.f, 29, cos(DegreesToRadians(300))*10.f);
        alphaTower.materials = @[towerMaterial];
        [bedNode addChildNode:alphaTowerNode];

        SCNBox *betaTower = [SCNBox boxWithWidth:1.f height:60.f length:1.f chamferRadius:0.2];
        SCNNode *betaTowerNode = [SCNNode nodeWithGeometry:betaTower];
        betaTowerNode.position = SCNVector3Make(sin(DegreesToRadians(60))*10.f, 29, cos(DegreesToRadians(60))*10.f);
        betaTower.materials = @[towerMaterial];
        [bedNode addChildNode:betaTowerNode];

        SCNBox *gammaTower = [SCNBox boxWithWidth:1.f height:60.f length:1.f chamferRadius:0.2];
        SCNNode *gammaTowerNode = [SCNNode nodeWithGeometry:gammaTower];
        gammaTowerNode.position = SCNVector3Make(sin(DegreesToRadians(180))*10.f, 29, cos(DegreesToRadians(180))*10.f);
        gammaTower.materials = @[towerMaterial];
        [bedNode addChildNode:gammaTowerNode];


            // Rotation to make labels vertical and pointing forward
        CATransform3D towerLabelRot = CATransform3DMakeRotation(DegreesToRadians(90), 0, 0, 1);

            // Label the towers
        SCNText *alphaText = [SCNText textWithString:@"Alpha (X)" extrusionDepth:4.f];
        SCNNode *alphaTextNode = [SCNNode nodeWithGeometry:alphaText];
        alphaTextNode.transform = towerLabelRot;
        alphaTextNode.position = SCNVector3Make(0.5f, -29, 0);
        alphaTextNode.transform = CATransform3DScale(alphaTextNode.transform, .025f, .025f, .025f);
        alphaText.materials = @[towerLabelMaterial];
        [alphaTowerNode addChildNode:alphaTextNode];

        SCNText *betaText = [SCNText textWithString:@"Beta (Y)" extrusionDepth:4.f];
        SCNNode *betaTextNode = [SCNNode nodeWithGeometry:betaText];
        betaTextNode.transform = towerLabelRot;
        betaTextNode.position = SCNVector3Make(0.5f, -29, 0);
        betaTextNode.transform = CATransform3DScale(betaTextNode.transform, .025f, .025f, .025f);
        betaText.materials = @[towerLabelMaterial];
        [betaTowerNode addChildNode:betaTextNode];

        SCNText *gammaText = [SCNText textWithString:@"Gamma (Z)" extrusionDepth:4.f];
        SCNNode *gammaTextNode = [SCNNode nodeWithGeometry:gammaText];
        gammaTextNode.transform = towerLabelRot;
        gammaTextNode.position = SCNVector3Make(0.5f, -29, 0);
        gammaTextNode.transform = CATransform3DScale(gammaTextNode.transform, .025f, .025f, .025f);
        gammaText.materials = @[towerLabelMaterial];
        [gammaTowerNode addChildNode:gammaTextNode];
        }


    if(showPoints)
        {
            // Use a white glass material for the tower labels
        SCNMaterial *pointLabelMaterial = [SCNMaterial material];
        pointLabelMaterial.diffuse.contents  = [NSColor whiteColor];
        pointLabelMaterial.specular.contents = [NSColor blackColor];
        pointLabelMaterial.shininess = 1.0;
        pointLabelMaterial.transparency = 0.6f;

        for (int i = 0; i < 7; i++)
            {
            for (int j = 0; j < 7; j++)
                {
                    // Use a white glass material for the tower labels
                SCNMaterial *pointMaterial = [SCNMaterial material];
                pointMaterial.diffuse.contents  = [NSColor blackColor];
                pointMaterial.specular.contents = [NSColor whiteColor];
                pointMaterial.shininess = 1.0;
                pointMaterial.transparency = 1;

                SCNSphere *point = [SCNSphere sphereWithRadius:0.1f];
                SCNNode *pointNode = [SCNNode nodeWithGeometry:point];
                pointNode.position = SCNVector3Make((j-4) * (8.5f/4.0f), points[j][i] * 10.f, (i-4) * (8.5f/4.0f));
                point.materials = @[pointMaterial];
                [bedNode addChildNode:pointNode];

                if(showPointLabels)
                    {
                    NSString *label = [NSString stringWithFormat:@"%1.3f", points[i][j]];
                    SCNText *pointLabel = [SCNText  textWithString: label extrusionDepth:4.f];
                    SCNNode *pointLabelNode = [SCNNode nodeWithGeometry:pointLabel];
                    pointLabelNode.position = SCNVector3Make(0, (points[i][j]>0)?0.1f:-0.1f, 0);
                    pointLabelNode.transform = CATransform3DScale(pointLabelNode.transform, .01f, .01f, .01f);
                    pointLabel.materials = @[pointLabelMaterial];
                    [pointNode addChildNode:pointLabelNode];

                    }
                if(showLines)
                    {
                    }
                }
            }

        if(showPlane)
            {
            for (int j = 0; j < 7; j++)
                {
                for (int i = 0; i < 7; i++)
                    {
                    NSLog (@"Element (%i,%i) = %f", i, j, points[i][j]);
                    }
                }
            }




        if(spin)
            {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            animation.values = [NSArray arrayWithObjects:
                                [NSValue valueWithCATransform3D:CATransform3DRotate(bedNode.transform, 0 * M_PI / 2, 1.f, 0.5f, 0.f)],
                                [NSValue valueWithCATransform3D:CATransform3DRotate(bedNode.transform, 1 * M_PI / 2, 1.f, 0.5f, 0.f)],
                                [NSValue valueWithCATransform3D:CATransform3DRotate(bedNode.transform, 2 * M_PI / 2, 1.f, 0.5f, 0.f)],
                                [NSValue valueWithCATransform3D:CATransform3DRotate(bedNode.transform, 3 * M_PI / 2, 1.f, 0.5f, 0.f)],
                                [NSValue valueWithCATransform3D:CATransform3DRotate(bedNode.transform, 4 * M_PI / 2, 1.f, 0.5f, 0.f)],
                                nil];
            animation.duration = 3.f;
            animation.repeatCount = HUGE_VALF;
            
            [bedNode addAnimation:animation forKey:@"transform"];
            }
        
        
        }
}

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};


@end
