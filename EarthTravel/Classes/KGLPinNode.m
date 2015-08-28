//
//  KGLPinNode.m
//
//  Created by Kevin Li on 3/2/15.
//  Copyright (c) 2015 Kevin Li. All rights reserved.
//

#import "KGLPinNode.h"
#import <SpriteKit/SpriteKit.h>
#import "KGLDefines.h"
#import "UtilManager.h"

@interface KGLPinNode ()

@end

@implementation KGLPinNode

+ (KGLPinNode *)pinAtLatitude:(float)latitude
                 andLongitude:(float)longitude
                        title:(NSString*)title
                  countryCode:(NSString*)countryCode
{
    KGLPinNode *pin = [super node];

    if (pin) {
        pin.latitude = latitude;
        pin.longitude = longitude;
        pin.countryCode = countryCode;
    }
    
    pin.name = @"pinWrapper";

    SCNBox* pinScene = [SCNBox boxWithWidth:1.0 height:1.0 length:1.0*108.0/159.0 chamferRadius:0];

    //SCNPyramid* pinScene = [SCNPyramid pyramidWithWidth:1.0 height:1.0 length:1.0];
    SCNNode *pinNode = [SCNNode nodeWithGeometry:pinScene];
    NSString* strCountryImagePath = [NSString stringWithFormat: @"icon_%@", countryCode];
    {
        // ambient light
        SCNMaterial *greenMaterial              = [SCNMaterial material];
        greenMaterial.diffuse.contents          = [UIColor clearColor];
        greenMaterial.locksAmbientWithDiffuse   = YES;
        
        SCNMaterial *redMaterial                = [SCNMaterial material];
        redMaterial.diffuse.contents            = [UIColor clearColor];
        redMaterial.locksAmbientWithDiffuse     = YES;
        
        SCNMaterial *blueMaterial               = [SCNMaterial material];
        blueMaterial.diffuse.contents           = [UIColor clearColor];
        blueMaterial.locksAmbientWithDiffuse    = YES;
        
        SCNMaterial *yellowMaterial             = [SCNMaterial material];
        yellowMaterial.diffuse.contents         = [UIColor clearColor];
        yellowMaterial.locksAmbientWithDiffuse  = YES;
        
        SCNMaterial *purpleMaterial             = [SCNMaterial material];
        purpleMaterial.diffuse.contents         = strCountryImagePath; // 위를 쳐다보는 면
        purpleMaterial.locksAmbientWithDiffuse  = YES;
        
        SCNMaterial *magentaMaterial            = [SCNMaterial material];
        magentaMaterial.diffuse.contents        = [UIColor clearColor];
        magentaMaterial.locksAmbientWithDiffuse = YES;
        
        
        pinScene.materials =  @[greenMaterial,  redMaterial,    blueMaterial,
                           yellowMaterial, purpleMaterial, magentaMaterial];
    }
    
    // add the pin geometry to the pin node
    [pin addChildNode:pinNode];
    
    // pins are small, especially from directly above or zoomed out, so wrap a larger rectangular node around the pin
    // this will create a greater touch area
    SCNBox *touchBrick = [SCNBox boxWithWidth:5.0f height:7.5f length:5.0f chamferRadius:0];
    SCNNode *touchNode = [SCNNode nodeWithGeometry:touchBrick];
    touchNode.hidden = YES;
    touchNode.name = @"TouchPin";
    [pin addChildNode:touchNode];
    
    // position the pin
    // calculate the pin's position along the Y axis of the Earth, based on the given latitude
    float yPos = sinf(DEGREES_TO_RADIANS(latitude)) * 27.8f*ZOOME_RATIO;
    // calculate what the radius of the horizontal circle that cuts through the Earth is at the given Y position
    float localRadius = [KGLEarthCommonMath radiusOfCircleBisectingSphereOfRadius:27.8f*ZOOME_RATIO atHeight:yPos];
    // using the local radius, calculate the X and Z positions of the pin, based on the given longitude
    HorizontalCoords coords = [KGLEarthCommonMath horizontalCoordinatesAtDegrees:longitude ofSphereRadius:localRadius];
    pin.position = SCNVector3Make(-1 * coords.x, yPos, coords.z);
    
    // rotate the pin so it stands vertically at 90 degrees from the surface of the Earth
    // first, set the pin's euler angles such that it lies flat against the surface of the Earth, given the pin's location
    // the yaw angle positions the pin so it faces out from the surface of the Earth at its location
    float yawAngle = atan2f(-1 * coords.x, coords.z);
    // the pitch angle tilts the pin so it lies on the ground
    float pitchAngle = -1 * DEGREES_TO_RADIANS(latitude) - M_PI_2;
    pin.eulerAngles = SCNVector3Make(pitchAngle, yawAngle, 0);
    
    // now rotate the pin by 180 degrees vertically, so it stands up
    SCNMatrix4 latRotation = SCNMatrix4MakeRotation(DEGREES_TO_RADIANS(180),1, 0, 0);
    pin.transform = SCNMatrix4Mult(latRotation, pin.transform);
    
    //==============================
    // label
    //==============================
    SCNText *text = [SCNText textWithString:title extrusionDepth:0.1];
    
    SCNMaterial *magentaMaterial = [SCNMaterial material];
    magentaMaterial.diffuse.contents = [UtilManager colorWithHexString:@"ec4f30"];
    magentaMaterial.locksAmbientWithDiffuse = YES;
    text.materials = @[magentaMaterial];
    
    SCNNode *textNode = [SCNNode nodeWithGeometry:text];
    textNode.position = SCNVector3Make(-1+M_PI_2, 0, 0);
    textNode.transform = SCNMatrix4Mult(SCNMatrix4MakeScale(0.05, 0.05, 0.05), textNode.transform);
    [pin addChildNode:textNode];
        
    return pin;
}

@end
