    //
    //  MJDSceneView.m
    //  BedPlotter
    //
    //  Created by Mark Dunsford on 14/06/2014.
    //  Copyright (c) 2014 Mark Dunsford. All rights reserved.
    //

#import "MJDSceneView.h"

@interface MJDSceneView ()

@end

@implementation MJDSceneView

SCNNode *cameraNode;
SCNScene *scene;

bool spin = false;
bool showBed = true;
bool showTowers = true;
bool showFakes = false;
bool showPoints = true;
bool showPointLabels = true;
bool showLines = true;
bool showGrid = true;
bool showSurface = false;
bool showColourMap = true;
bool showWireFrame = true;
bool validData = false;

float points[7][7] = {
    { -0.138, -0.138, -0.138, -0.200, -0.300, -0.300, -0.300 },
    { -0.050, -0.050, -0.075, -0.113, -0.113, -0.138, -0.138 },
    { -0.138, -0.063, -0.025, -0.050, -0.063, -0.075,  0.050 },
    { -0.225, -0.188, -0.088, -0.050, -0.000,  0.037,  0.162 },
    { -0.275, -0.188, -0.150, -0.088, -0.075,  0.062,  0.212 },
    { -0.325, -0.325, -0.263, -0.138, -0.088,  0.112,  0.112 },
    {  0.087,   0.087,  0.087, -0.238,  0.012,  0.012,  0.012 } };


-(void)awakeFromNib
{
    [self updateUI];
}

-(void)setOptionsWithBedOn:(Boolean) mShowBed
                  towersOn:(Boolean) mShowTowers
                   fakesOn:(Boolean) mShowFakes
                  pointsOn:(Boolean) mShowPoints
             pointLabelsOn:(Boolean) mShowPointLabels
                   linesOn:(Boolean) mShowLines
                    gridOn:(Boolean) mShowGrid
                 surfaceOn:(Boolean) mShowSurface
               colourMapOn:(Boolean) mShowColourMap
               wireFrameOn:(Boolean) mShowWireFrame
{
    showBed = mShowBed;
    showTowers = mShowTowers;
    showFakes = mShowFakes;
    showPoints = mShowPoints;
    showPointLabels = mShowPointLabels;
    showLines = mShowLines;
    showGrid = mShowGrid;
    showSurface = mShowSurface;
    showColourMap = mShowColourMap;
    showWireFrame = mShowWireFrame;
}

-(void) setPoints:(NSString *) G29Data
{
    if ([[G29Data stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        validData = false;
        return;
    }
    else
        {
        validData = true;
        }

    NSArray *rows = [[G29Data stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (int y=0; y<7; y++)
        {
        if(y<rows.count)
            {
            NSArray *cols = [[rows[y] stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@" "];
            for (int x=0; x<7; x++)
                {
                points[y][x] = x<cols.count ? [cols[x] floatValue] : -1.0f;  // use -1 if point missing.
                }
            }
        else
                // Handle entire missing row
            {
            for (int x=0; x<7; x++)
                {
                points[y][x] = -1.0f;
                }
            }
        }

}

- (void) updateUI
{
    self.backgroundColor = [NSColor lightGrayColor];

        // Create an empty scene
    scene = [SCNScene scene];
    self.scene = scene;

        // Create a camera
    SCNCamera *camera = [SCNCamera camera];
    camera.xFov = 45;   // Degrees, not radians
    camera.yFov = 45;
    cameraNode = [SCNNode node];
    cameraNode.camera = camera;
    cameraNode.position = SCNVector3Make(0, 5, 18);
    cameraNode.rotation = SCNVector4Make(1, 0, 0, DegreesToRadians(-15));
    [scene.rootNode addChildNode:cameraNode];


        // Create ambient light
    SCNLight *ambientLight = [SCNLight light];
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLight.type = SCNLightTypeAmbient;
    ambientLight.color = [NSColor colorWithDeviceWhite:0.6 alpha:1.0];
    ambientLightNode.light = ambientLight;
    [scene.rootNode addChildNode:ambientLightNode];

        // Create the upper diffuse light
    SCNLight *diffuseLight = [SCNLight light];
    SCNNode *diffuseLightNode = [SCNNode node];
    diffuseLight.type = SCNLightTypeOmni;
    diffuseLightNode.light = diffuseLight;
    diffuseLightNode.position = SCNVector3Make(30, 25, 18);
    [scene.rootNode addChildNode:diffuseLightNode];

        // Create the lower diffuse light
    SCNLight *diffuseLight2 = [SCNLight light];
    SCNNode *diffuseLight2Node = [SCNNode node];
    diffuseLight2.type = SCNLightTypeOmni;
    diffuseLight2.color = [NSColor colorWithDeviceWhite:0.8 alpha:1.0];
    diffuseLight2Node.light = diffuseLight2;
    diffuseLight2Node.position = SCNVector3Make(-50, 30, -30);
    [scene.rootNode addChildNode:diffuseLight2Node];


        // Invisible material for hidden objects
    SCNMaterial *hiddenMaterial = [SCNMaterial material];
    hiddenMaterial.diffuse.contents = [NSColor clearColor];
    hiddenMaterial.specular.contents = [NSColor clearColor];

        // Invisible world cube to force camera pivot to centre
    SCNBox *world = [SCNBox boxWithWidth:100 height:100 length:100 chamferRadius:0];
    SCNNode *worldNode = [SCNNode nodeWithGeometry:world];
    world.materials = @[hiddenMaterial];
    [scene.rootNode addChildNode:worldNode];


        // Use a yellow kapton film material for the bed
    SCNMaterial *bedMaterial = [SCNMaterial material];
    bedMaterial.diffuse.contents  = [NSColor yellowColor];
    bedMaterial.specular.contents = [NSColor whiteColor];
    bedMaterial.shininess = 1.0;
    bedMaterial.transparency = showBed?0.3f:0.0f;
    bedMaterial.doubleSided = true;


        // Create a kapton disc for the reference bed
    SCNCylinder *bed = [SCNCylinder cylinderWithRadius:8.5 height:0.01];
    SCNNode *bedNode = [SCNNode nodeWithGeometry:bed];
    bed.materials = @[bedMaterial];
    [scene.rootNode addChildNode:bedNode];


        // Use a clear blue glass material for the glass bed
    SCNMaterial *glassMaterial = [SCNMaterial material];
    glassMaterial.diffuse.contents  = [NSColor blueColor];
    glassMaterial.specular.contents = [NSColor whiteColor];
    glassMaterial.shininess = 1.0;
    glassMaterial.transparency = showBed?0.02f:0.0f;
    glassMaterial.doubleSided = true;

        // Create a glass disc for the bed under the kapton film
    SCNCylinder *glass = [SCNCylinder cylinderWithRadius:8.5 height:0.2];
    SCNNode *glassNode = [SCNNode nodeWithGeometry:glass];
    glassNode.position = SCNVector3Make(0.f, -0.155f, 0.f);
    glass.materials = @[glassMaterial];
    [bedNode addChildNode:glassNode];

    if(showTowers)
        {
        [bedNode addChildNode: makeTowers() ];
        }


        // Rotation to make labels vertical and pointing forward
    CATransform3D gridXRot = CATransform3DMakeRotation(DegreesToRadians(90), 1, 0, 0);
    CATransform3D gridYRot = CATransform3DMakeRotation(DegreesToRadians(90), 0, 0, 1);

    for (int y = 0; y < 7; y++)
        {
            // Use a yellow material for the grid
        SCNMaterial *gridLineMaterial = [SCNMaterial material];
        gridLineMaterial.diffuse.contents  = [NSColor yellowColor];
        gridLineMaterial.specular.contents = [NSColor blackColor];
        gridLineMaterial.shininess = 1.0;
        gridLineMaterial.transparency = 1.f;
        gridLineMaterial.doubleSided = true;

        if(showGrid)
            {
            SCNCylinder *gridLine = [SCNCylinder cylinderWithRadius:0.01f height: getGridLength(y) ];
            gridLine.materials = @[gridLineMaterial];
            SCNNode *gridLineNode = [SCNNode nodeWithGeometry:gridLine];
            gridLineNode.transform = gridYRot;
            gridLineNode.position = SCNVector3Make(0, 0, (y-3) * (8.5f/4.0f));
            [bedNode addChildNode:gridLineNode];
            }

        for (int x = 0; x < 7; x++)
            {
            if(showGrid)
                {
                SCNCylinder *gridLine = [SCNCylinder cylinderWithRadius:0.01f height: getGridLength(x) ];
                gridLine.materials = @[gridLineMaterial];
                SCNNode *gridLineNode = [SCNNode nodeWithGeometry:gridLine];
                gridLineNode.transform = gridXRot;
                gridLineNode.position = SCNVector3Make( ( x - 3 ) * ( 8.5f / 4.0f ), 0, 0);
                [bedNode addChildNode:gridLineNode];
                }

            if(showPoints && validData)
                {
                    // Colour code the point markers according to distance from the bed
                SCNMaterial *pointMaterial = [SCNMaterial material];
                pointMaterial.diffuse.contents  = getPointColor(points[y][x]);
                pointMaterial.specular.contents = [NSColor whiteColor];
                pointMaterial.shininess = 1.0;
                pointMaterial.transparency = isFake(x,y) ? ( showFakes ? 0.2f : 0.0f ) : 1.f;

                SCNSphere *point = [SCNSphere sphereWithRadius:0.15f];
                point.materials = @[pointMaterial];
                SCNNode *pointNode = [SCNNode nodeWithGeometry:point];
                pointNode.position = SCNVector3Make( ( x - 3 ) * ( 8.5f / 4.0f), (points[y][x] * 10.f), ( y - 3 ) * ( 8.5f / 4.0f ) );

                if(showPointLabels)
                    {
                        // Use a white glass material for the point labels
                    SCNMaterial *pointLabelMaterial = [SCNMaterial material];
                    pointLabelMaterial.diffuse.contents  = [NSColor blackColor];
                    pointLabelMaterial.specular.contents = [NSColor whiteColor];
                    pointLabelMaterial.shininess = 1.0;
                    pointLabelMaterial.transparency = isFake(x,y) ? ( showFakes ? 0.2f : 0.0f ) : 1.0f;

                    NSString *label = [NSString stringWithFormat:@"%1.3f", points[y][x]];
                    SCNText *pointLabel = [SCNText  textWithString: label extrusionDepth:2.f];
                    pointLabel.materials = @[pointLabelMaterial];
                    SCNNode *pointLabelNode = [SCNNode nodeWithGeometry:pointLabel];
                    pointLabelNode.position = SCNVector3Make(-0.1f, ( (points[y][x]>=0) ? 0.1f : -0.6f ), 0);
                    pointLabelNode.transform = CATransform3DScale(pointLabelNode.transform, .01f, .01f, .01f);

                    [pointNode addChildNode:pointLabelNode];
                    }

                [bedNode addChildNode:pointNode];
                }

            if(showLines && validData)
                {
                    // Colour code the point marker lines according to distance of the point from the bed
                SCNMaterial *lineMaterial = [SCNMaterial material];
                lineMaterial.diffuse.contents  = getPointColor(points[y][x]);
                lineMaterial.specular.contents = [NSColor whiteColor];
                lineMaterial.shininess = 1.0;
                lineMaterial.transparency = isFake(x,y) ? ( showFakes ? 0.2f : 0.0f ) : 1.f;

                SCNCylinder *bar = [SCNCylinder cylinderWithRadius:0.1f height: fabsf(((points[y][x] * 10.f))) ];
                bar.materials = @[lineMaterial];
                SCNNode *barNode = [SCNNode nodeWithGeometry:bar];
                barNode.position = SCNVector3Make((x-3) * (8.5f/4.0f), (points[y][x] * 5.f), (y-3) * (8.5f/4.0f));
                [bedNode addChildNode:barNode];
                }
            }


        if(showSurface && validData)
            {
                // Use a white (appears grey) material for the bed plane
            SCNMaterial *planeMaterial = [SCNMaterial material];
            planeMaterial.diffuse.contents  = [NSColor whiteColor];
            planeMaterial.specular.contents = [NSColor whiteColor];
            planeMaterial.shininess = 1.0;
            planeMaterial.transparency = 1.f;
            planeMaterial.doubleSided = true;

                // Give the plane an image-based diffuse (colour map)
            SCNMaterial *ColourMapmaterial = [SCNMaterial material];
            NSImage *diffuseImage =  maketextureImage();
            ColourMapmaterial.diffuse.contents  = diffuseImage;
            ColourMapmaterial.specular.contents = [NSColor whiteColor];
            ColourMapmaterial.shininess = 1.0;
            ColourMapmaterial.diffuse.minificationFilter = SCNLinearFiltering;
            ColourMapmaterial.diffuse.magnificationFilter = SCNLinearFiltering;
            ColourMapmaterial.diffuse.mipFilter = SCNLinearFiltering;
            ColourMapmaterial.doubleSided = true;

            SCNGeometry *geometry = makeSurface();

            geometry.materials = @[showColourMap ? ColourMapmaterial : planeMaterial];

            SCNNode *planeNode = [SCNNode nodeWithGeometry:geometry];
            planeNode.position = SCNVector3Make(0, 0, 0);
            [bedNode addChildNode:planeNode];
            }


        if(showWireFrame && validData)
            {
                // Use a black material for the wireframe
            SCNMaterial *wireFrameMaterial = [SCNMaterial material];
            wireFrameMaterial.diffuse.contents  = [NSColor blackColor];
            wireFrameMaterial.specular.contents = [NSColor whiteColor];
            wireFrameMaterial.shininess = 1.0;
            wireFrameMaterial.transparency = 1.0f;
            wireFrameMaterial.doubleSided = true;

            SCNGeometry *geometry = makeWireFrame();

            geometry.materials = @[wireFrameMaterial];

            SCNNode *planeNode = [SCNNode nodeWithGeometry:geometry];
            planeNode.position = SCNVector3Make(0, 0, 0);
            [bedNode addChildNode:planeNode];
            }

        }
}

SCNNode* makeTowers()
{
    SCNNode *towerNode = [[SCNNode alloc] init];

        // Use a blue glass material for the towers
    SCNMaterial *towerMaterial = [SCNMaterial material];
    towerMaterial.diffuse.contents  = [NSColor blueColor];
    towerMaterial.specular.contents = [NSColor whiteColor];
    towerMaterial.shininess = 1.0;
    towerMaterial.transparency = 0.04;
    towerMaterial.doubleSided = true;

        // Add the towers
    SCNBox *alphaTower = [SCNBox boxWithWidth:1.f height:60.f length:1.f chamferRadius:0.2];
    SCNNode *alphaTowerNode = [SCNNode nodeWithGeometry:alphaTower];
    alphaTowerNode.position = SCNVector3Make(sin(DegreesToRadians(300))*10.f, 29, cos(DegreesToRadians(300))*10.f);
    alphaTower.materials = @[towerMaterial];
    [towerNode addChildNode:alphaTowerNode];

    SCNBox *betaTower = [SCNBox boxWithWidth:1.f height:60.f length:1.f chamferRadius:0.2];
    SCNNode *betaTowerNode = [SCNNode nodeWithGeometry:betaTower];
    betaTowerNode.position = SCNVector3Make(sin(DegreesToRadians(60))*10.f, 29, cos(DegreesToRadians(60))*10.f);
    betaTower.materials = @[towerMaterial];
    [towerNode addChildNode:betaTowerNode];

    SCNBox *gammaTower = [SCNBox boxWithWidth:1.f height:60.f length:1.f chamferRadius:0.2];
    SCNNode *gammaTowerNode = [SCNNode nodeWithGeometry:gammaTower];
    gammaTowerNode.position = SCNVector3Make(sin(DegreesToRadians(180))*10.f, 29, cos(DegreesToRadians(180))*10.f);
    gammaTower.materials = @[towerMaterial];
    [towerNode addChildNode:gammaTowerNode];


        // Rotation to make labels vertical and pointing forward
    CATransform3D towerLabelRot = CATransform3DMakeRotation(DegreesToRadians(90), 0, 0, 1);

        // Use a dark grey glass material for the tower labels
    SCNMaterial *towerLabelMaterial = [SCNMaterial material];
    towerLabelMaterial.diffuse.contents  = [NSColor darkGrayColor];
    towerMaterial.specular.contents = [NSColor blackColor];
    towerLabelMaterial.shininess = 1.0;
    towerLabelMaterial.transparency = 1;
    towerLabelMaterial.doubleSided = true;

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

    return towerNode;
}


SCNGeometry* makeSurface()
{
    SCNVector3 positions[98];
    SCNVector3 normals[98];
    CGPoint textures[98];

    int indices[36 * 2 * 3 * 2];

    for (int y = 0; y < 7; y++)
        {
        for (int x = 0; x < 7; x++)
            {
            int x1 = showFakes?x:validX(x, y);
            int y1 = showFakes?y:validY(x, y);
            positions[ ( y * 7 ) + x ] = SCNVector3Make((x1-3) * (8.5f/4.0f), (points[y1][x1] * 10.f), (y1-3) * (8.5f/4.0f));
            positions[ ( y * 7 ) + x + 49 ] = SCNVector3Make((x1-3) * (8.5f/4.0f), (points[y1][x1] * 10.f)-0.01f, (y1-3) * (8.5f/4.0f));

            normals[ ( y * 7 ) + x ] = SCNVector3Make(0,1,0);//(x1-3) * (8.5f/4.0f), (points[y1][x1] * 10.f), (y1-3) * (8.5f/4.0f));
            normals[ ( y * 7 ) + x + 49 ] = SCNVector3Make(0,1,0);//(x1-3) * (8.5f/4.0f), (points[y1][x1] * 10.f)+0.01f, (y1-3) * (8.5f/4.0f));

            textures[ ( y * 7 ) + x ] = CGPointMake((float)x/7, (float)y/7);
            textures[ ( y * 7 ) + x + 49 ] = CGPointMake((float)x/7, (float)y/7);

            int upperBase = ( ( ( y * 6 ) + x ) * 6 );
            int lowerBase = ( ( ( y * 6 ) + x ) * 6 ) + (36 * 2 * 3);

            if(x<6 && y<6)
                {
                indices[upperBase]     = ( x + 0 ) + ( ( y + 1 ) * 7 ) ;
                indices[upperBase + 1] = ( x + 1 ) + ( ( y + 1 ) * 7 ) ;
                indices[upperBase + 2] = ( x + 0 ) + ( ( y + 0 ) * 7 ) ;

                indices[upperBase + 3] = ( x + 1 ) + ( ( y + 1 ) * 7 ) ;
                indices[upperBase + 4] = ( x + 1 ) + ( ( y + 0 ) * 7 ) ;
                indices[upperBase + 5] = ( x + 0 ) + ( ( y + 0 ) * 7 ) ;

                indices[lowerBase]     = ( x + 0 ) + ( ( y + 1 ) * 7 ) + 49 ;
                indices[lowerBase + 1] = ( x + 0 ) + ( ( y + 0 ) * 7 ) + 49 ;
                indices[lowerBase + 2] = ( x + 1 ) + ( ( y + 1 ) * 7 ) + 49 ;

                indices[lowerBase + 3] = ( x + 1 ) + ( ( y + 1 ) * 7 ) + 49 ;
                indices[lowerBase + 4] = ( x + 0 ) + ( ( y + 0 ) * 7 ) + 49 ;
                indices[lowerBase + 5] = ( x + 1 ) + ( ( y + 0 ) * 7 ) + 49 ;
                }
            }
        }

    SCNGeometrySource *vertexSource = [SCNGeometrySource geometrySourceWithVertices:positions count:98];
    SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithNormals:normals count:98];
    SCNGeometrySource *textureSource = [SCNGeometrySource geometrySourceWithTextureCoordinates:textures count:98];


    NSData *indexData = [NSData dataWithBytes:indices length:sizeof(indices)];

    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indexData
                                                                primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                               primitiveCount:(36 * 2 * 2)
                                                                bytesPerIndex:sizeof(int)];

    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[vertexSource, normalSource, textureSource]
                                                    elements:@[element]];
    return geometry;
}


SCNGeometry* makeWireFrame()
{
    SCNVector3 positions[98];
    SCNVector3 normals[98];
    CGPoint textures[98];

    int indices[36 * 2 * 3 * 2];

    for (int y = 0; y < 7; y++)
        {
        for (int x = 0; x < 7; x++)
            {
            int x1 = showFakes?x:validX(x, y);
            int y1 = showFakes?y:validY(x, y);
            positions[ ( y * 7 ) + x ] = SCNVector3Make((x1-3) * (8.5f/4.0f), (points[y1][x1] * 10.f), (y1-3) * (8.5f/4.0f));
            positions[ ( y * 7 ) + x + 49 ] = SCNVector3Make((x1-3) * (8.5f/4.0f), (points[y1][x1]-(showSurface?0.04:0) * 10.f), (y1-3) * (8.5f/4.0f));
            normals[ ( y * 7 ) + x ] = SCNVector3Make(0,-1,0);//(x1-3) * (8.5f/4.0f), (points[y1][x1] * 10.f), (y1-3) * (8.5f/4.0f));
            normals[ ( y * 7 ) + x + 49 ] = SCNVector3Make(0,1,0);//(x1-3) * (8.5f/4.0f), (points[y1][x1] * 10.f)-(showSurface?0.04:0), (y1-3) * (8.5f/4.0f));
            textures[ ( y * 7 ) + x ] = CGPointMake((float)x/7, (float)y/7);
            textures[ ( y * 7 ) + x + 49 ] = CGPointMake((float)x/7, (float)y/7);

            int upperBase = ( ( ( y * 6 ) + x ) * 6 );
            int lowerBase = ( ( ( y * 6 ) + x ) * 6 ) + (36 * 2 * 3);

            if(x<6 && y<6)
                {
                indices[upperBase]     = ( x + 0 ) + ( ( y + 1 ) * 7 ) ;
                indices[upperBase + 1] = ( x + 1 ) + ( ( y + 1 ) * 7 ) ;
                indices[upperBase + 2] = ( x + 0 ) + ( ( y + 0 ) * 7 ) ;

                indices[upperBase + 3] = ( x + 1 ) + ( ( y + 1 ) * 7 ) ;
                indices[upperBase + 4] = ( x + 1 ) + ( ( y + 0 ) * 7 ) ;
                indices[upperBase + 5] = ( x + 0 ) + ( ( y + 0 ) * 7 ) ;

                indices[lowerBase]     = ( x + 0 ) + ( ( y + 1 ) * 7 ) + 49 ;
                indices[lowerBase + 1] = ( x + 0 ) + ( ( y + 0 ) * 7 ) + 49 ;
                indices[lowerBase + 2] = ( x + 1 ) + ( ( y + 1 ) * 7 ) + 49 ;

                indices[lowerBase + 3] = ( x + 1 ) + ( ( y + 1 ) * 7 ) + 49 ;
                indices[lowerBase + 4] = ( x + 0 ) + ( ( y + 0 ) * 7 ) + 49 ;
                indices[lowerBase + 5] = ( x + 1 ) + ( ( y + 0 ) * 7 ) + 49 ;
                }
            }
        }

    SCNGeometrySource *vertexSource = [SCNGeometrySource geometrySourceWithVertices:positions count:98];
    SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithNormals:normals count:98];
    SCNGeometrySource *textureSource = [SCNGeometrySource geometrySourceWithTextureCoordinates:textures count:98];


    NSData *indexData = [NSData dataWithBytes:indices length:sizeof(indices)];

    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indexData
                                                                primitiveType:SCNGeometryPrimitiveTypeLine
                                                               primitiveCount:(36 * 2 * 2)
                                                                bytesPerIndex:sizeof(int)];

    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[vertexSource, normalSource, textureSource]
                                                    elements:@[element]];
    return geometry;
}



NSImage* maketextureImage()
{
    int width = 7;
    int height = 7;

    char* rgba = (char*)malloc(width*height*4);

    for (int y = 0; y < height; y++)
        {
        for (int x = 0; x < width; x++)
            {
            int i = y * height + x;
            NSColor* colour = getPointColor(points[y][x]);

            rgba[4*i+0] = colour.redComponent * 128;
            rgba[4*i+1] = colour.greenComponent * 128;
            rgba[4*i+2] = colour.blueComponent * 255;
            rgba[4*i+3] = 255;
            }
        }

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(
                                                       rgba,
                                                       width,
                                                       height,
                                                       8, // bitsPerComponent
                                                       4*width, // bytesPerRow
                                                       colorSpace,
                                                       (CGBitmapInfo)kCGImageAlphaNoneSkipLast);

    CFRelease(colorSpace);

    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);

    NSSize size = NSMakeSize(7, 7);
    NSImage* image = [[NSImage alloc] initWithCGImage:cgImage size:size];

    CFRelease(cgImage);
    CFRelease(bitmapContext);
    free(rgba);
    
    return image;
}


CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

NSColor* getPointColor(float value)
{
    float blue = value>0?(value<0.25f?value*4.f:1.f):0.f;
    float red = value<0?(-value<0.25f?-value*4.f:1.f):0.f;
    float green = 1.f - (red);

    return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha: 1.0f ];
}

float getGridLength(int row)
{
    float segment = ( 8.5f / 4.0f );

    switch (row) {
        case 0:
        case 6:
            return segment * 3.0f;
            break;

        case 1:
        case 5:
            return segment * 5.0f;
            break;

        case 2:
        case 3:
        case 4:
            return segment * 7.0f;
            break;

        default:
            return 0;
            break;
    }
}

Boolean isFake(int x, int y)
{
    if ( (x==0 || x==6) && (y==0 || y==1 || y==5 || y==6) )
        {
        return true;
        }
    else if ( (x==1 || x==5) && (y==0 || y==6) )
        {
        return true;
        }
    else
        {
        return false;
        }
}

int validX(int x, int y)
{
    return x;
    switch (y) {
        case 0:
        case 6:
            return ( x<2 ? 2 : ( x>4 ? 4 : x ) );
            break;
            
        case 1:
        case 5:
            return ( x<1 ? 1 : ( x>5 ? 5 : x ) );
            break;
            
        case 2:
        case 3:
        case 4:
            return x;
            break;
            
        default:
            return 0;
            break;
    }
}

int validY(int x, int y)
{
    switch (x) {
        case 0:
        case 6:
            return ( y<2 ? 2 : ( y>4 ? 4 : y ) );
            break;
            
        case 1:
        case 5:
            return ( y<1 ? 1 : ( y>5 ? 5 : y ) );
            break;
            
        case 2:
        case 3:
        case 4:
            return y;
            break;
            
        default:
            return 0;
            break;
    }
}

-(void)homeCamera
{
    self.pointOfView = cameraNode;
}


    //workaround until Snapshot method is available (osX 10.10 and iOS 8)
- (NSImage*)imageFromSceneKitView:(SCNView*)sceneKitView
{
    NSInteger width = sceneKitView.bounds.size.width * self.window.backingScaleFactor;
    NSInteger height = sceneKitView.bounds.size.height * self.window.backingScaleFactor;
    NSBitmapImageRep* imageRep=[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                       pixelsWide:width
                                                                       pixelsHigh:height
                                                                    bitsPerSample:8
                                                                  samplesPerPixel:4
                                                                         hasAlpha:YES
                                                                         isPlanar:NO
                                                                   colorSpaceName:NSCalibratedRGBColorSpace
                                                                      bytesPerRow:width*4
                                                                     bitsPerPixel:4*8];
    [[sceneKitView openGLContext] makeCurrentContext];
    glReadPixels(0, 0, (int)width, (int)height, GL_RGBA, GL_UNSIGNED_BYTE, [imageRep bitmapData]);
    [NSOpenGLContext clearCurrentContext];
    NSImage* outputImage = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    [outputImage addRepresentation:imageRep];
    NSImage* flippedImage = [NSImage imageWithSize:NSMakeSize(width, height) flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
        [imageRep drawInRect:dstRect];
        return YES;
    }];
    return flippedImage;
}


-(void)print:(id)sender{
    [[NSPrintInfo sharedPrintInfo] setHorizontalPagination:NSFitPagination];
    [[NSPrintInfo sharedPrintInfo] setVerticalPagination:NSFitPagination];
    [[NSPrintInfo sharedPrintInfo] setOrientation:NSLandscapeOrientation];

    NSImage *image = [self imageFromSceneKitView:self];
    NSImage *newImage = [[NSImage alloc] initWithSize:[[NSPrintInfo sharedPrintInfo] imageablePageBounds].size];

    [newImage lockFocus];

    [image drawInRect:[[NSPrintInfo sharedPrintInfo] imageablePageBounds]
             fromRect:NSMakeRect(0.0,
                                 0.0,
                                 [image size].width,
                                 [image size].height)
            operation:NSCompositeCopy
             fraction:1.0];

    [newImage unlockFocus];

    NSImageView *printView = [[NSImageView alloc]
                              initWithFrame:[[NSPrintInfo sharedPrintInfo] imageablePageBounds]];

    [printView setImageScaling:NSScaleProportionally];

    [printView setImage:newImage];
    
    [printView print:sender];
}


@end
