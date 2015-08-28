//
//  EarthTravelViewController.m
//  EarthTravel
//
//  Created by NakCheonJung on 6/26/15.
//  Copyright (c) 2015 ncjung. All rights reserved.
//

#import "EarthTravelViewController.h"
#import <GLKit/GLKit.h>
#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h>
#import "KGLPinNode.h"
#import "KGLEarthCoordinate.h"
#import "CitiesHaveBeenMapMarkerView.h"

#pragma mark - enum Definition

/******************************************************************************
 * enum Definition
 *****************************************************************************/


/******************************************************************************
 * String Definition
 *****************************************************************************/


/******************************************************************************
 * Constant Definition
 *****************************************************************************/
#define SLIDE_COUNT 1
#define ZOOME_RATIO 1

/******************************************************************************
 * Function Definition
 *****************************************************************************/
#define MAX_RY (M_PI_4*1.5)

/******************************************************************************
 * Type Definition
 *****************************************************************************/

@interface EarthTravelViewController() <SCNSceneRendererDelegate>
{
    //scene
    SCNView *_selfSceneView;
    SCNScene *_scene;
    
    // save spot light transform
    SCNMatrix4 _originalSpotTransform;
    
    //references to nodes for manipulation
    SCNNode *_cameraHandle;
    SCNNode *_cameraOrientation;
    SCNNode *_cameraNode;
    SCNNode *_ambientLightNode;
    SCNNode *_floorNode;
    SCNNode *_spotLightParentNode;
    SCNNode *_spotLightNode;
    SCNNode *_mainWall;
    SCNNode *_invisibleWallForPhysicsSlide;
    NSMutableArray* _arrayWalls;
    
    //shaders slide
    SCNNode *_shaderGroupNode;
    SCNNode *_shadedNode;
    int      _shaderStage;
    
    // shader modifiers
    NSString *_geomModifier;
    NSString *_surfModifier;
    NSString *_fragModifier;
    NSString *_lightModifier;
    
    //camera manipulation
    SCNMatrix4 _cameraHandleTransforms;
    CGPoint _initialOffset;
    CGPoint _lastOffset;
    CGPoint _lastSpinOffset;
    
    // pins
    NSMutableArray *_currentPins;
    CitiesHaveBeenMapMarkerView* _viewContryInfo;
    
    // spin
    SCNNode* _sunHandleNode;
    SCNNode* _cloudsNode;
    UIPinchGestureRecognizer* _pinchGesture;
}
@end

@interface EarthTravelViewController(CreateMethods)
-(BOOL)createSceneView;
-(BOOL)createEnvironment;
-(BOOL)createSceneElements;
-(BOOL)createIntroEnvironment;

@end

@interface EarthTravelViewController(PrivateMethods)
-(BOOL)privateInitializeSetting;
-(BOOL)privateInitializeUI;
-(BOOL)privateSetupSceneSettings;
-(BOOL)privateShowNextShaderStage;
-(BOOL)privateTiltCameraWithOffset:(CGPoint)offset;
-(BOOL)privateHandlePanAtPoint:(CGPoint)p;
-(BOOL)privateRestoreCameraAngle;
@end

@interface EarthTravelViewController(PrivateServerCommunications)
@end

@interface EarthTravelViewController(selectors)
-(void)selectorHandleTap:(UIGestureRecognizer *)gestureRecognizer;
-(void)selectorHandlePan:(UIGestureRecognizer *)gestureRecognizer;
-(void)selectorHandleDoubleTap:(UIGestureRecognizer *)gestureRecognizer;
-(void)selectorHandlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer;
@end

@interface EarthTravelViewController(IBActions)
@end

@interface EarthTravelViewController(ProcessMethod)
@end


/******************************************************************************************
 * Implementation
 ******************************************************************************************/
@implementation EarthTravelViewController

#pragma mark - class life cycle

-(id)init
{
    self = [super init];
    if (self) {
        NSLog(@"EarthTravelViewController::INIT");
    }
    return self;
}

- (void)loadView
{
    self.view = [[SCNView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


-(void)prepareForRelease
{
    
}

-(void)dealloc
{
    NSLog(@"EarthTravelViewController::DEALLOC");
}

//#pragma mark - SYSTEM
//
//-(BOOL)prefersStatusBarHidden
//{
//    return NO;
//}
//
//-(NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
//}
//
//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

#pragma mark - operations

-(void)initialize
{
    [self privateInitializeSetting];
    [self privateInitializeUI];
}

//-(BOOL)hasFullScreenView
//{
//    return NO;
//}

-(void)dropPinsAtLocations:(NSArray *)pinArray
{
    // remove any existing pins
    for (SCNNode *node in _currentPins) {
        [node removeFromParentNode];
    }
    _currentPins = [NSMutableArray array];
    
    // create new pins
    for (KGLEarthCoordinate *coord in pinArray) {
        KGLPinNode *newPin = [KGLPinNode pinAtLatitude:coord.latitude
                                          andLongitude:coord.longitude
                                                 title:coord.pinIdentifier
                                           countryCode:coord.contryCode];
        if (coord.pinIdentifier) {
            newPin.identifier = coord.pinIdentifier;
        }
        [_shadedNode addChildNode:newPin];
        [_currentPins addObject:newPin];
    }
}

-(void)runAnimation
{
    _shadedNode.eulerAngles = SCNVector3Make(0, 0, 0);
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"AllCititesToTravel_258" ofType:@"plist"];
    NSDictionary* objectData = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray* arrayList = [objectData valueForKeyPath:@"list"];
    __block int index = 0;
    
    NSMutableArray *animationPoints = [[NSMutableArray alloc] init];
    // wait 3sec
    {
        SCNAction* actionWait = [SCNAction waitForDuration:1.0];
        [animationPoints addObject:actionWait];
    }
    float lastLat = 0.0;
    float lastLng = 0.0;
    for (NSDictionary* dicInfo in arrayList) {
        NSString* cityName = dicInfo[@"dest_name"];
        float latitude = [dicInfo[@"lat"] floatValue];
        float longitude = [dicInfo[@"lng"] floatValue];
        // background
        {
            for (SCNNode* nodeWall in _arrayWalls) {
                nodeWall.opacity = 1.0;
            }
            _invisibleWallForPhysicsSlide.hidden = YES;
            _mainWall.opacity = 1.0;
            _floorNode.opacity = 1.0;
        }
        // wait 0.5
        {
            SCNAction* actionWait = [SCNAction waitForDuration:1.0];
            [animationPoints addObject:actionWait];
        }
        // animation group
        {
            NSMutableArray* arrayGroup = [[NSMutableArray alloc] init];
            // opacity
            {
                SCNAction* actionBlock = [SCNAction runBlock:^(SCNNode *node) {
                    NSLog(@"cityName=%@, %f, %f", cityName, latitude, longitude);
                    for (KGLPinNode* pin in _currentPins) {
                        if (![pin.identifier isEqualToString:cityName]) {
                            pin.opacity = 0.5;
                            pin.scale = SCNVector3Make(1.0, 1.0, 1.0);
                        }
                        else {
                            pin.opacity = 1.0;
                            pin.scale = SCNVector3Make(2.0, 2.0, 2.0);
                        }
                    }
                }];
                [arrayGroup addObject:actionBlock];
            }
            // calculate
            {
                float degreeX = ((45 - latitude)/1) * (M_PI/180.0);
                float degreeY = ((lastLng - longitude)/1) * (M_PI/180.0);
                
                SCNAction* action = [SCNAction rotateByX:0
                                                       y:degreeY
                                                       z:0
                                                duration:1.0];
                [arrayGroup addObject:action];
                SCNAction* actionBlock = [SCNAction runBlock:^(SCNNode *node) {
                    [SCNTransaction begin];
                    [SCNTransaction setAnimationDuration:1.0];
                    _cameraHandle.eulerAngles = SCNVector3Make(degreeX, 0, 0);
                    float offset = latitude;
                    float offsetZ = latitude;
                    if (latitude < 0 && latitude >= -10) {
                        offset = 20-latitude;
                        offsetZ = -20-latitude;
                    }
                    else if (latitude < -10 && latitude >= -20) {
                        offset = 10-latitude;
                        offsetZ = -40-latitude;
                    }
                    else if (latitude < -20 && latitude >= -30) {
                        offset = -0-latitude;
                        offsetZ = -60-latitude;
                    }
                    else if (latitude < -30 && latitude >= -40) {
                        offset = -20-latitude;
                        offsetZ = -80-latitude;
                    }
                    else if (latitude < -40 && latitude >= -50) {
                        offset = -30-latitude;
                        offsetZ = -90-latitude;
                    }
                    else if (latitude < -50) {
                        offset = -30-latitude;
                        offsetZ = -100-latitude;
                    }
                    
                    if (lastLat > 60) {
                        offsetZ -= 15;
                    }
                    _cameraHandle.position = SCNVector3Make(_cameraHandle.position.x, 60+40+(30-offset), -40+(20-offsetZ));
                    [SCNTransaction commit];
                }];
                [arrayGroup addObject:actionBlock];
                
                SCNAction* actionViewBlock = [SCNAction runBlock:^(SCNNode *node) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (_viewContryInfo) {
                            [_viewContryInfo removeFromSuperview];
                            _viewContryInfo = nil;
                        }
                        _viewContryInfo = [[CitiesHaveBeenMapMarkerView alloc] init];
                        [_selfSceneView addSubview:_viewContryInfo];
                        _viewContryInfo.frame = CGRectMake(0,
                                                           0,
                                                           100,
                                                           45);
                        _viewContryInfo.cityName = cityName;
                        _viewContryInfo.countryCode = [dicInfo objectForKey:@"country_code"];
                        _viewContryInfo.countryName = [dicInfo objectForKey:@"country_name"];
                        _viewContryInfo.dicUserInfo = [NSDictionary dictionaryWithDictionary:dicInfo];
                        [_viewContryInfo initialize];
                        _viewContryInfo.frame = CGRectMake((self.view.frame.size.width - _viewContryInfo.frame.size.width)/2,
                                                           30,
                                                           _viewContryInfo.frame.size.width,
                                                           _viewContryInfo.frame.size.height);
                        NSLog(@"xx");
                    });
                }];
                [arrayGroup addObject:actionViewBlock];
                
                SCNAction* actionGroup = [SCNAction group:arrayGroup];
                [animationPoints addObject:actionGroup];
                
                lastLat = latitude;
                lastLng = longitude;
            }
        }
        
        ++index;
    }
    
    // warp up animation gruop
    {
        NSMutableArray* arrayGroup = [[NSMutableArray alloc] init];
        // opacity
        {
            SCNAction* actionBlock = [SCNAction runBlock:^(SCNNode *node) {
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:1.0];
                for (KGLPinNode* pin in _currentPins) {
                    pin.opacity = 1.0;
                    pin.scale = SCNVector3Make(1.0, 1.0, 1.0);
                }
                _shadedNode.eulerAngles = SCNVector3Make(0, 0, -18.029/180.0 * M_PI);
                _cameraHandle.position = SCNVector3Make(_cameraHandle.position.x, 60, 0);
                
                // hide
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_viewContryInfo) {
                        [_viewContryInfo removeFromSuperview];
                        _viewContryInfo = nil;
                    }
                    for (UIView* view in _selfSceneView.subviews) {
                        if ([view isKindOfClass:[UIView class]]) {
                            [view removeFromSuperview];
                        }
                    }
                    for (SCNNode* nodeWall in _arrayWalls) {
                        nodeWall.opacity = 0.0;
                    }
                });
                _mainWall.opacity = 0.0;
                _floorNode.opacity = 0.0;
                [SCNTransaction commit];
            }];
            [arrayGroup addObject:actionBlock];
        }
        // move
        {
            SCNAction* action = [SCNAction moveTo:SCNVector3Make(_shadedNode.position.x/*숫자가 커질수록 오른쪽으로 간다.*/,
                                                                 0,
                                                                 0/*숫자가 커질수록 앞으로 온다.*/)
                                         duration:0.5];
            [arrayGroup addObject:action];
        }
        
        [animationPoints addObject:arrayGroup];
    }
    SCNAction *actionSequence = [SCNAction sequence:animationPoints];
    [_shadedNode runAction:actionSequence];
}

-(void)stopAnimation
{
    [_shadedNode removeAllActions];
    
    // warp up animation gruop
    NSMutableArray *animationPoints = [[NSMutableArray alloc] init];
    {
        NSMutableArray* arrayGroup = [[NSMutableArray alloc] init];
        // opacity
        {
            SCNAction* actionBlock = [SCNAction runBlock:^(SCNNode *node) {
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:1.0];
                for (KGLPinNode* pin in _currentPins) {
                    pin.opacity = 1.0;
                    pin.scale = SCNVector3Make(1.0, 1.0, 1.0);
                }
                _shadedNode.eulerAngles = SCNVector3Make(0, 0, -18.029/180.0 * M_PI);
                _cameraHandle.position = SCNVector3Make(_cameraHandle.position.x, 60, 0);
                
                // hide
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_viewContryInfo) {
                        [_viewContryInfo removeFromSuperview];
                        _viewContryInfo = nil;
                    }
                    for (UIView* view in _selfSceneView.subviews) {
                        if ([view isKindOfClass:[UIView class]]) {
                            [view removeFromSuperview];
                        }
                    }
                });
                for (SCNNode* nodeWall in _arrayWalls) {
                    nodeWall.opacity = 0.0;
                }
                _mainWall.opacity = 0.0;
                _floorNode.opacity = 0.0;
                [SCNTransaction commit];
            }];
            [arrayGroup addObject:actionBlock];
        }
        // move
        {
            SCNAction* action = [SCNAction moveTo:SCNVector3Make(_shadedNode.position.x/*숫자가 커질수록 오른쪽으로 간다.*/,
                                                                 0,
                                                                 0/*숫자가 커질수록 앞으로 온다.*/)
                                         duration:0.5];
            [arrayGroup addObject:action];
        }
        
        [animationPoints addObject:arrayGroup];
    }
    SCNAction *actionSequence = [SCNAction sequence:animationPoints];
    [_shadedNode runAction:actionSequence];
}

-(void)spinAnimation
{
    // background
    for (SCNNode* nodeWall in _arrayWalls) {
        nodeWall.opacity = 0.0;
    }
    _mainWall.opacity = 0.0;
    _floorNode.opacity = 0.0;
    
    _shadedNode.eulerAngles = SCNVector3Make(0, 0, -18.029/180.0 * M_PI);
    _cameraHandle.position = SCNVector3Make(_cameraHandle.position.x, 60, 0);
    _cameraHandle.eulerAngles = SCNVector3Make(0, 0, 0);

//    // cloud
//    _cloudsNode = [SCNNode node];
//    {
//        _cloudsNode.geometry = [SCNSphere sphereWithRadius:30];
//        [_shadedNode addChildNode:_cloudsNode];
//
//        _cloudsNode.opacity = 0.5;
//
//        // This effect can also be achieved with an image with some transparency set as the contents of the 'diffuse' property
//        _cloudsNode.geometry.firstMaterial.transparent.contents = @"cloudsTransparency.png";
//        _cloudsNode.geometry.firstMaterial.transparencyMode = SCNTransparencyModeRGBZero;
//    }
    
    // spin
    [_shadedNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:M_PI z:0 duration:6.0]]];
//    [_cloudsNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:(18.029/180.0 * M_PI) z:(-18.029/180.0 * M_PI) duration:12.0]]];
    
    // original light
    _spotLightNode.light.color = [SKColor colorWithWhite:0.2 alpha:1.0];
    
    //animate light
    _sunHandleNode = [SCNNode node];
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeDirectional;
    lightNode.light.castsShadow = YES;
    lightNode.light.color = [SKColor colorWithWhite:0.8 alpha:1.0];
    lightNode.light.shadowColor = [SKColor colorWithWhite:0 alpha:0.5];
    [_sunHandleNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:-M_PI*2 z:0 duration:3.0]]];
    [_sunHandleNode addChildNode:lightNode];

    [_shadedNode addChildNode:_sunHandleNode];
    
    
    // gestures
    {
        NSMutableArray *gestureRecognizers = [NSMutableArray array];
        [gestureRecognizers addObjectsFromArray:_selfSceneView.gestureRecognizers];
        
        UIPanGestureRecognizer* panGesture = nil;
        for (id gesture in gestureRecognizers) {
            if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
                panGesture = gesture;
            }
        }
        
        // pinch
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(selectorHandlePinchGesture:)];
        [panGesture requireGestureRecognizerToFail:_pinchGesture];
        [gestureRecognizers addObject:_pinchGesture];
        
        //register gesture recognizers
        _selfSceneView.gestureRecognizers = gestureRecognizers;
    }
}

-(void)stopSpinAnimation
{
    // background
    for (SCNNode* nodeWall in _arrayWalls) {
        nodeWall.opacity = 0.0;
    }
    _mainWall.opacity = 0.0;
    _floorNode.opacity = 0.0;
    
    [_shadedNode removeAllActions];
    
    // original light
    _spotLightNode.light.color = [SKColor colorWithWhite:1.0 alpha:1.0];
    [_sunHandleNode removeFromParentNode];
    [_cloudsNode removeFromParentNode];
    
    // gesture remove
    {
        NSMutableArray *gestureRecognizers = [NSMutableArray array];
        [gestureRecognizers addObjectsFromArray:_selfSceneView.gestureRecognizers];
        
        UIPinchGestureRecognizer* pinGesture = nil;
        for (id gesture in gestureRecognizers) {
            if ([gesture isEqual:_pinchGesture]) {
                pinGesture = gesture;
            }
        }
        [gestureRecognizers removeObject:pinGesture];
        _pinchGesture = nil;
        _selfSceneView.gestureRecognizers = gestureRecognizers;
    }
    
}

#pragma mark - create methods

-(BOOL)createSceneView
{
    _selfSceneView = (SCNView *)self.view;
    
    //redraw forever
    _selfSceneView.playing = YES;
    _selfSceneView.loops = YES;
    _selfSceneView.showsStatistics = YES;
    
    _selfSceneView.backgroundColor = [SKColor blackColor];
    
    return YES;
}

-(BOOL)createEnvironment
{
    // |_   cameraHandle
    //   |_   cameraOrientation
    //     |_   cameraNode
    
    //create a main camera
    _cameraNode = [SCNNode node];
    _cameraNode.position = SCNVector3Make(0, 0, 120);
    
    //create a node to manipulate the camera orientation
    _cameraHandle = [SCNNode node];
    _cameraHandle.position = SCNVector3Make(0, 60, 0);
    
    _cameraOrientation = [SCNNode node];
    
    [_scene.rootNode addChildNode:_cameraHandle];
    [_cameraHandle addChildNode:_cameraOrientation];
    [_cameraOrientation addChildNode:_cameraNode];
    
    _cameraNode.camera = [SCNCamera camera];
    _cameraNode.camera.zFar = 800;
    _cameraNode.camera.yFov = 55;
    _cameraHandleTransforms = _cameraNode.transform;
    
    // add an ambient light
    _ambientLightNode = [SCNNode node];
    _ambientLightNode.light = [SCNLight light];
    
    _ambientLightNode.light.type = SCNLightTypeAmbient;
    _ambientLightNode.light.color = [SKColor colorWithWhite:0.3 alpha:1.0];
    
    [_scene.rootNode addChildNode:_ambientLightNode];
    
    
    //add a key light to the scene
    _spotLightParentNode = [SCNNode node];
    _spotLightParentNode.position = SCNVector3Make(0, 90, 20);
    
    _spotLightNode = [SCNNode node];
    _spotLightNode.rotation = SCNVector4Make(1,0,0,-M_PI_4);
    
    _spotLightNode.light = [SCNLight light];
    _spotLightNode.light.type = SCNLightTypeSpot;
    _spotLightNode.light.color = [SKColor colorWithWhite:1.0 alpha:1.0];
    _spotLightNode.light.castsShadow = YES;
    _spotLightNode.light.shadowColor = [SKColor colorWithWhite:0.0 alpha:0.5];
    _spotLightNode.light.zNear = 30;
    _spotLightNode.light.zFar = 800;
    _spotLightNode.light.shadowRadius = 1.0;
    _spotLightNode.light.spotInnerAngle = 15;
    _spotLightNode.light.spotOuterAngle = 70;
    
    [_cameraNode addChildNode:_spotLightParentNode];
    [_spotLightParentNode addChildNode:_spotLightNode];
    
    //save spotlight transform
    _originalSpotTransform = _spotLightNode.transform;
    
    //floor
    SCNFloor *floor = [SCNFloor floor];
    floor.reflectionFalloffEnd = 0;
    floor.reflectivity = 0;
    
    _floorNode = [SCNNode node];
    _floorNode.geometry = floor;
    _floorNode.geometry.firstMaterial.diffuse.contents = @"wood.png";
    _floorNode.geometry.firstMaterial.locksAmbientWithDiffuse = YES;
    _floorNode.geometry.firstMaterial.diffuse.wrapS = SCNWrapModeRepeat;
    _floorNode.geometry.firstMaterial.diffuse.wrapT = SCNWrapModeRepeat;
    _floorNode.geometry.firstMaterial.diffuse.mipFilter = SCNFilterModeNearest;
    _floorNode.geometry.firstMaterial.doubleSided = NO;
    
    _floorNode.physicsBody = [SCNPhysicsBody staticBody];
    _floorNode.physicsBody.restitution = 1.0;
    
    [_scene.rootNode addChildNode:_floorNode];
    return YES;
}

-(BOOL)createSceneElements
{
    // create the wall geometry
    SCNPlane *wallGeometry = [SCNPlane planeWithWidth:800 height:200];
    wallGeometry.firstMaterial.diffuse.contents = @"wallPaper.png";
    wallGeometry.firstMaterial.diffuse.contentsTransform = SCNMatrix4Mult(SCNMatrix4MakeScale(8, 2, 1), SCNMatrix4MakeRotation(M_PI_4, 0, 0, 1));
    wallGeometry.firstMaterial.diffuse.wrapS = SCNWrapModeRepeat;
    wallGeometry.firstMaterial.diffuse.wrapT = SCNWrapModeRepeat;
    wallGeometry.firstMaterial.doubleSided = NO;
    wallGeometry.firstMaterial.locksAmbientWithDiffuse = YES;
    
    SCNNode *wallWithBaseboardNode = [SCNNode nodeWithGeometry:wallGeometry];
    wallWithBaseboardNode.position = SCNVector3Make(200, 100, -20);
    wallWithBaseboardNode.physicsBody = [SCNPhysicsBody staticBody];
    wallWithBaseboardNode.physicsBody.restitution = 1.0;
    wallWithBaseboardNode.castsShadow = NO;
    
    SCNNode *baseboardNode = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:800 height:8 length:0.5 chamferRadius:0]];
    baseboardNode.geometry.firstMaterial.diffuse.contents = @"baseboard.jpg";
    baseboardNode.geometry.firstMaterial.diffuse.wrapS = SCNWrapModeRepeat;
    baseboardNode.geometry.firstMaterial.doubleSided = NO;
    baseboardNode.geometry.firstMaterial.locksAmbientWithDiffuse = YES;
    baseboardNode.position = SCNVector3Make(0, -wallWithBaseboardNode.position.y + 4, 0.5);
    baseboardNode.castsShadow = NO;
    baseboardNode.renderingOrder = -3; //render before others
    
    [wallWithBaseboardNode addChildNode:baseboardNode];
    
    //front walls
    _mainWall = wallWithBaseboardNode;
    [_scene.rootNode addChildNode:wallWithBaseboardNode];
    _mainWall.renderingOrder = -3; //render before others
    
    //back
    SCNNode *wallNode = [wallWithBaseboardNode clone];
    wallNode.opacity = 0;
    wallNode.physicsBody = [SCNPhysicsBody staticBody];
    wallNode.physicsBody.restitution = 1.0;
    wallNode.physicsBody.categoryBitMask = 1 << 2;
    wallNode.castsShadow = NO;
    
    wallNode.position = SCNVector3Make(0, 100, 40);
    wallNode.rotation = SCNVector4Make(0, 1, 0, M_PI);
    [_scene.rootNode addChildNode:wallNode];
    
    //left
    wallNode = [wallWithBaseboardNode clone];
    wallNode.position = SCNVector3Make(-120, 100, 40);
    wallNode.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    [_scene.rootNode addChildNode:wallNode];
    if (!_arrayWalls) {
        _arrayWalls = [[NSMutableArray alloc] init];
    }
    [_arrayWalls addObject:wallNode];
    
    
    //right (an invisible wall to keep the bodies in the visible area when zooming in the Physics slide)
    wallNode = [wallNode clone];
    wallNode.opacity = 0;
    wallNode.position = SCNVector3Make(120, 100, 40);
    wallNode.rotation = SCNVector4Make(0, 1, 0, -M_PI_2);
    _invisibleWallForPhysicsSlide = wallNode;
    
    //right (the actual wall on the right)
    wallNode = [wallWithBaseboardNode clone];
    wallNode.physicsBody = nil;
    wallNode.position = SCNVector3Make(600, 100, 40);
    wallNode.rotation = SCNVector4Make(0, 1, 0, -M_PI_2);
    [_scene.rootNode addChildNode:wallNode];
    [_arrayWalls addObject:wallNode];
    
    //top
    [baseboardNode removeFromParentNode];
    wallNode = [wallWithBaseboardNode clone];
    wallNode.physicsBody = nil;
    wallNode.position = SCNVector3Make(200, 200, 0);
    wallNode.scale = SCNVector3Make(1, 1, 1);
    wallNode.rotation = SCNVector4Make(1, 0, 0, M_PI_2);
    [_scene.rootNode addChildNode:wallNode];
    [_arrayWalls addObject:wallNode];
    
    wallNode = [wallWithBaseboardNode clone];
    wallNode.physicsBody = nil;
    wallNode.position = SCNVector3Make(200, 200, 200);
    wallNode.scale = SCNVector3Make(1, 1, 1);
    wallNode.rotation = SCNVector4Make(1, 0, 0, M_PI_2);
    [_scene.rootNode addChildNode:wallNode];
    [_arrayWalls addObject:wallNode];
    
    _mainWall.hidden = NO;
    return YES;
}

-(BOOL)createIntroEnvironment
{
    _shaderStage = 0;
    
    //place camera
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:1.0];
    _cameraHandle.position = SCNVector3Make(_cameraHandle.position.x+180, 60, 0);
    _cameraHandle.eulerAngles = SCNVector3Make(0, 0, 0);
    
    _spotLightNode.light.spotOuterAngle = 55;
    [SCNTransaction commit];
    
    _shaderGroupNode = [SCNNode node];
    _shaderGroupNode.position = SCNVector3Make(_cameraHandle.position.x+0/*숫자가 커질수록 오른쪽으로 가고, 구가 타원이 된다.*/,
                                               60/*숫자가 커질수록 위로 올라간다.*/,
                                               0/*숫자가 커질수록 앞으로 온다.*/);
    [_scene.rootNode addChildNode:_shaderGroupNode];
    
    //add globe stand
    SCNNode *globe = [SCNNode node];
    //globe.pivot = SCNMatrix4MakeTranslation(0.5, 0.5, 0.5);
    globe.position = SCNVector3Make(0/*숫자가 커질수록 오른쪽으로 간다.*/, 0, 0/*숫자가 커질수록 앞으로 온다.*/);
    globe.eulerAngles = SCNVector3Make(0, 0, -18.029/180.0 * M_PI);
    [_shaderGroupNode addChildNode:globe];
    _shaderGroupNode.renderingOrder -= 3;
    
    // toy style
    {
        //show shader modifiers
        //add spheres
        globe.geometry = [SCNSphere sphereWithRadius:28];
        //globe.geometry.segmentCount = 48;
        globe.geometry.firstMaterial.diffuse.contents = @"earth-diffuse-toy.jpg";
        globe.geometry.firstMaterial.specular.contents = @"earth-specular-toy.jpg";
        globe.geometry.firstMaterial.specular.intensity = 0.2;
        
        globe.geometry.firstMaterial.shininess = 0.1;
        globe.geometry.firstMaterial.reflective.contents = @"envmap.jpg";
        globe.geometry.firstMaterial.reflective.intensity = 0.5;
        globe.geometry.firstMaterial.fresnelExponent = 2;
    }
    
    // real style
    {
//        globe.geometry = [SCNSphere sphereWithRadius:28];
//        globe.geometry.firstMaterial.ambient.intensity = 1;
//        globe.geometry.firstMaterial.normal.intensity = 1;
//        globe.geometry.firstMaterial.reflective.intensity = 0.2;
//        globe.geometry.firstMaterial.reflective.contents = [UIColor whiteColor];
//        globe.geometry.firstMaterial.fresnelExponent = 3.0;
//        
//        globe.geometry.firstMaterial.emission.intensity = 1;
//        globe.geometry.firstMaterial.diffuse.contents = @"earth-diffuse.jpg";
//        
//        globe.geometry.firstMaterial.shininess = 0.1;
//        globe.geometry.firstMaterial.specular.contents = @"earth-specular.jpg";
//        globe.geometry.firstMaterial.specular.intensity = 0.8;
//        
//        globe.geometry.firstMaterial.normal.contents = @"earth-bump.png";
//        globe.geometry.firstMaterial.normal.intensity = 1.3;
//        
//        globe.geometry.firstMaterial.emission.contents = @"earth-emissive.jpg";
//        globe.geometry.firstMaterial.emission.intensity = 1.0;
//        
//        // Use a shader modifier to display an environment map independently of the lighting model used
//        globe.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointFragment :
//                                                @" _output.color.rgb -= _surface.reflective.rgb * _lightingContribution.diffuse;"
//                                            @"_output.color.rgb += _surface.reflective.rgb;" };
//
    }
    
    //GEOMETRY
    globe.scale = SCNVector3Make(1.5, 1.5, 1.5);
    
    _geomModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_geom" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    _surfModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_surf" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    _fragModifier = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_frag" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    _lightModifier= [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sm_light" ofType:@"shader"] encoding:NSUTF8StringEncoding error:nil];
    
    [globe.geometry setValue:@0.0 forKey:@"Amplitude"];
    [globe.geometry setValue:@0.0 forKey:@"lightIntensity"];
    [globe.geometry setValue:@0.0 forKey:@"surfIntensity"];
    [globe.geometry setValue:@0.0 forKey:@"fragIntensity"];
    
    _shadedNode = globe;
    
    //redraw forever
    ((SCNView*)self.view).playing = YES;
    ((SCNView*)self.view).loops = YES;
    
    return YES;
}

#pragma mark - private methods

-(BOOL)privateInitializeSetting
{
    SCNView *sceneView = (SCNView *)self.view;
    
    //redraw forever
    sceneView.playing = YES;
    sceneView.loops = YES;
    sceneView.showsStatistics = YES;
    
    sceneView.backgroundColor = [SKColor blackColor];
    
    return YES;
}

-(BOOL)privateInitializeUI
{
    _scene = [SCNScene scene];
    
    [self createSceneView];
    [self createEnvironment];
    [self createSceneElements];
    [self createIntroEnvironment];
    [self privateSetupSceneSettings];
    
    // background
    {
        for (SCNNode* nodeWall in _arrayWalls) {
            nodeWall.opacity = 0.0;
        }
        _mainWall.opacity = 0.0;
        _floorNode.opacity = 0.0;
    }

    // add pin
    {        
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"AllCititesToTravel_258" ofType:@"plist"];
        NSDictionary* objectData = [NSDictionary dictionaryWithContentsOfFile:filePath];
        
        NSArray* arrayList = [objectData valueForKeyPath:@"list"];
        NSMutableArray* arrayCordinate = [[NSMutableArray alloc] init];
        for (NSDictionary* dicInfo in arrayList) {
            
            NSString* cityName = dicInfo[@"dest_name"];
            float lat = [dicInfo[@"lat"] floatValue];
            float lng = [dicInfo[@"lng"] floatValue];
            NSString* countryCode = [dicInfo objectForKey:@"country_code"];
            
            // drop some pins
            KGLEarthCoordinate *pin = [KGLEarthCoordinate coordinateWithLatitude:lat
                                                                    andLongitude:lng
                                                                andPinIdentifier:cityName
                                                                  andConturyCode:countryCode];
            [arrayCordinate addObject:pin];
        }
        [self dropPinsAtLocations:arrayCordinate];
    }
    return YES;
}

-(BOOL)privateSetupSceneSettings
{
    //present it
    _selfSceneView.scene = _scene;
    
    //tweak physics
    _selfSceneView.scene.physicsWorld.speed = 2.0;
    
    //let's be the delegate of the SCNView
    _selfSceneView.delegate = self;
    
    //initial point of view
    _selfSceneView.pointOfView = _cameraNode;
    
    // gestures
    {
        NSMutableArray *gestureRecognizers = [NSMutableArray array];
        [gestureRecognizers addObjectsFromArray:_selfSceneView.gestureRecognizers];
        
        // add a tap gesture recognizer
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectorHandleTap:)];
        
        // add a pan gesture recognizer
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selectorHandlePan:)];
        
        // add a double tap gesture recognizer
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectorHandleDoubleTap:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        
        // pinch
        //UIPinchGestureRecognizer* pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(selectorHandlePinchGesture:)];
        
        [tapGesture requireGestureRecognizerToFail:panGesture];
        //[panGesture requireGestureRecognizerToFail:pinchGesture];
        
        [gestureRecognizers addObject:doubleTapGesture];
        [gestureRecognizers addObject:tapGesture];
        [gestureRecognizers addObject:panGesture];
        //[gestureRecognizers addObject:pinchGesture];
        
        //register gesture recognizers
        _selfSceneView.gestureRecognizers = gestureRecognizers;
    }
    return YES;
}

-(BOOL)privateShowNextShaderStage
{
    // shader change
    _shaderStage++;
    
    //retrieve the node that owns the shader modifiers
    SCNNode *node = _shadedNode;
    
    switch(_shaderStage){
        case 1: // Geometry
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:1.];
            node.geometry.shaderModifiers = @{SCNShaderModifierEntryPointGeometry : _geomModifier,
                                              SCNShaderModifierEntryPointLightingModel : _lightModifier };
            
            [node.geometry setValue:@3.0 forKey:@"Amplitude"];
            [node.geometry setValue:@0.25 forKey:@"Frequency"];
            [node.geometry setValue:@0.0 forKey:@"lightIntensity"];
            [SCNTransaction commit];
            break;
        case 2: // Surface
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            [node.geometry setValue:@0.0 forKey:@"Amplitude"];
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:1.5];
                node.geometry.shaderModifiers = @{SCNShaderModifierEntryPointSurface : _surfModifier,
                                                  SCNShaderModifierEntryPointLightingModel : _lightModifier };
                [node.geometry setValue:@1.0 forKey:@"surfIntensity"];
                [SCNTransaction commit];
            }];
            [SCNTransaction commit];
        } break;
        case 3: // Fragment
        {
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            [node.geometry setValue:@0.0 forKey:@"surfIntensity"];
            [SCNTransaction setCompletionBlock:^{
                [SCNTransaction begin];
                [SCNTransaction setAnimationDuration:1.5];
                node.geometry.shaderModifiers = @{SCNShaderModifierEntryPointFragment : _fragModifier,
                                                  SCNShaderModifierEntryPointLightingModel : _lightModifier};
                [node.geometry setValue:@1.0 forKey:@"fragIntensity"];
                [node.geometry setValue:@1.0 forKey:@"lightIntensity"];
                [SCNTransaction commit];
            }];
            [SCNTransaction commit];
        }
            
            break;
        case 4: // None
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            [node.geometry setValue:@0.0 forKey:@"fragIntensity"];
            [node.geometry setValue:@0.0 forKey:@"lightIntensity"];
            _shaderStage = 0;
            [SCNTransaction setCompletionBlock:^{
                node.geometry.shaderModifiers = @{ SCNShaderModifierEntryPointFragment :
                                                       @" _output.color.rgb -= _surface.reflective.rgb * _lightingContribution.diffuse;"
                                                   @"_output.color.rgb += _surface.reflective.rgb;" };
            }];
            [SCNTransaction commit];
            break;
    }
    return YES;
}

// tilt the camera based on an offset
-(BOOL)privateTiltCameraWithOffset:(CGPoint)offset
{
    offset.x += _initialOffset.x;
    offset.y += _initialOffset.y;
    
    CGPoint tr;
    tr.x = offset.x - _lastOffset.x;
    tr.y = offset.y - _lastOffset.y;
    
    _lastOffset = offset;
    
    offset.x *= 0.1;
    offset.y *= 0.1;
    float rx = offset.y; //offset.y > 0 ? log(1 + offset.y * offset.y) : -log(1 + offset.y * offset.y);
    float ry = offset.x; //offset.x > 0 ? log(1 + offset.x * offset.x) : -log(1 + offset.x * offset.x);
    
    ry *= 0.05;
    rx *= 0.05;
    
    rx = -rx; //on iOS, invert rotation on the X axis
    
    if (rx > 0.5) {
        rx = 0.5;
        _initialOffset.y -=tr.y;
        _lastOffset.y -= tr.y;
    }
    if (rx < -M_PI_2) {
        rx = -M_PI_2;
        _initialOffset.y -=tr.y;
        _lastOffset.y -= tr.y;
    }
    
    if (ry > MAX_RY) {
        ry = MAX_RY;
        _initialOffset.x -=tr.x;
        _lastOffset.x -= tr.x;
    }
    if (ry < -MAX_RY) {
        ry = -MAX_RY;
        _initialOffset.x -=tr.x;
        _lastOffset.x -= tr.x;
        
    }
    
    ry = -ry;
    
    _cameraHandle.eulerAngles = SCNVector3Make(rx, ry, 0);
    
    return YES;
}

-(BOOL)privateHandlePanAtPoint:(CGPoint)offset
{
    //NSLog(@"privateHandlePanAtPoint%@", NSStringFromCGPoint(offset));
    //NSLog(@"privateHandlePanAtPoint(_initialOffset)=%@", NSStringFromCGPoint(_initialOffset));
    
    if (CGPointEqualToPoint(_lastSpinOffset, CGPointZero)) {
        _lastSpinOffset = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    }
    
    //[_shadedNode removeAllActions];
    _cameraHandle.eulerAngles = SCNVector3Make(-M_PI*((offset.y-_lastSpinOffset.y)*3/[UIScreen mainScreen].bounds.size.height),
                                               -M_PI*((offset.x-_lastSpinOffset.x)*3/[UIScreen mainScreen].bounds.size.width),
                                               0);

    // 최대로 확대할때
//    SCNAction* action = [SCNAction rotateByX:M_PI*((offset.x-([UIScreen mainScreen].bounds.size.width/2))/[UIScreen mainScreen].bounds.size.width)/100
//                                           y:M_PI*((offset.y-([UIScreen mainScreen].bounds.size.height/2))/[UIScreen mainScreen].bounds.size.height)/100
//                                           z:0.0
//                                    duration:0.0];
//    [_shadedNode runAction:action];
    return YES;
}

//restore the default camera orientation and position
-(BOOL)privateRestoreCameraAngle
{
    //reset drag offset
    _initialOffset = CGPointMake(0, 0);
    _lastOffset = _initialOffset;
    
    //restore default camera
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.5];
    [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    _cameraHandle.eulerAngles = SCNVector3Make(0, 0, 0);
    [SCNTransaction commit];
    
    return YES;
}

#pragma mark - selectors

-(void)selectorHandleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self privateShowNextShaderStage];
}

-(void)selectorHandlePan:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint p = [gestureRecognizer locationInView:self.view];
        _lastSpinOffset = p;
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self.view];
        _lastSpinOffset = p;
        _initialOffset = _lastOffset;
        return;
    }
    
    if (gestureRecognizer.numberOfTouches == 2) {
        [self privateTiltCameraWithOffset:[(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view]];
    }
    else {
        CGPoint p = [gestureRecognizer locationInView:self.view];
        [self privateHandlePanAtPoint:p];
    }
}

-(void)selectorHandleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self privateRestoreCameraAngle];
}

-(void)selectorHandlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer
{
    double degree = (gestureRecognizer.scale * [UIScreen mainScreen].scale);
    NSLog(@"selectorHandlePinchGesture=%f, %f", gestureRecognizer.scale * [UIScreen mainScreen].scale, _shadedNode.position.z);

    //[_shadedNode removeAllActions];
    
    if (degree*16 > 80) {
        return;
    }
    _shadedNode.position = SCNVector3Make(_shadedNode.position.x/*숫자가 커질수록 오른쪽으로 간다.*/,
                                          -degree*6,
                                          degree*16/*숫자가 커질수록 앞으로 온다.*/);
}

#pragma mark - SCNSceneRendererDelegate

//@optional

///*!
// @method renderer:updateAtTime:
// @abstract Implement this to perform per-frame game logic. Called exactly once per frame before any animation and actions are evaluated and any physics are simulated.
// @param aRenderer The renderer that will render the scene.
// @param time The time at which to update the scene.
// @discussion All modifications done within this method don't go through the transaction model, they are directly applied on the presentation tree.
// */
//- (void)renderer:(id <SCNSceneRenderer>)aRenderer updateAtTime:(NSTimeInterval)time SCENEKIT_AVAILABLE(10_10, 8_0);
//
///*!
// @method renderer:didApplyAnimationsAtTime:
// @abstract Invoked on the delegate once the scene renderer did apply the animations.
// @param aRenderer The renderer that did render the scene.
// @param time The time at which the animations were applied.
// @discussion All modifications done within this method don't go through the transaction model, they are directly applied on the presentation tree.
// */
//- (void)renderer:(id <SCNSceneRenderer>)aRenderer didApplyAnimationsAtTime:(NSTimeInterval)time SCENEKIT_AVAILABLE(10_10, 8_0);
//
///*!
// @method renderer:didSimulatePhysicsAtTime:
// @abstract Invoked on the delegate once the scene renderer did simulate the physics.
// @param aRenderer The renderer that did render the scene.
// @param time The time at which the physics were simulated.
// @discussion All modifications done within this method don't go through the transaction model, they are directly applied on the presentation tree.
// */
//- (void)renderer:(id <SCNSceneRenderer>)aRenderer didSimulatePhysicsAtTime:(NSTimeInterval)time SCENEKIT_AVAILABLE(10_10, 8_0);
//
///*!
// @method renderer:willRenderScene:atTime:
// @abstract Invoked on the delegate before the scene renderer renders the scene. At this point the openGL context and the destination framebuffer are bound.
// @param aRenderer The renderer that will render the scene.
// @param scene The scene to be rendered.
// @param time The time at which the scene is to be rendered.
// @discussion Starting in 10.10 all modifications done within this method don't go through the transaction model, they are directly applied on the presentation tree.
// */
//- (void)renderer:(id <SCNSceneRenderer>)aRenderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time;
//
///*!
// @method renderer:didRenderScene:atTime:
// @abstract Invoked on the delegate once the scene renderer did render the scene.
// @param aRenderer The renderer that did render the scene.
// @param scene The rendered scene.
// @param time The time at which the scene was rendered.
// @discussion Starting in 10.10 all modifications done within this method don't go through the transaction model, they are directly applied on the presentation tree.
// */
//- (void)renderer:(id <SCNSceneRenderer>)aRenderer didRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time;

@end
