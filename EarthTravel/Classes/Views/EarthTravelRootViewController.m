//
//  EarthTravelRootViewController.m
//  EarthTravel
//
//  Created by NakCheonJung on 6/28/15.
//  Copyright (c) 2015 ncjung. All rights reserved.
//

#import "EarthTravelRootViewController.h"
#import "EarthTravelViewController.h"
#import "UtilManager.h"
#import "IQProjectVideo.h"
#import <MediaPlayer/MediaPlayer.h>

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


/******************************************************************************
 * Function Definition
 *****************************************************************************/


/******************************************************************************
 * Type Definition
 *****************************************************************************/

@interface EarthTravelRootViewController()
{
    EarthTravelViewController* _earthViewController;
    UIButton* _btnRecord;
    UIButton* _btnRun;
    UIButton* _btnSpin;
    IQProjectVideo* _projectVideo;
}
@end

@interface EarthTravelRootViewController(CreateMethods)
@end

@interface EarthTravelRootViewController(PrivateMethods)
-(BOOL)privateInitializeSetting;
-(BOOL)privateInitializeUI;
@end

@interface EarthTravelRootViewController(PrivateServerCommunications)
@end

@interface EarthTravelRootViewController(selectors)
-(void)selectorRecordButtonClicked:(id)sender;
-(void)selectorRunButtonClicked:(id)sender;
-(void)selectorSpinButtonClicked:(id)sender;
@end

@interface EarthTravelRootViewController(IBActions)
@end

@interface EarthTravelRootViewController(ProcessMethod)
@end


/******************************************************************************************
 * Implementation
 ******************************************************************************************/
@implementation EarthTravelRootViewController

#pragma mark - class life cycle

-(id)init
{
    self = [super init];
    if (self) {
        NSLog(@"EarthTravelRootViewController::INIT");
    }
    return self;
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
    NSLog(@"EarthTravelRootViewController::DEALLOC");
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

#pragma mark - private methods

-(BOOL)privateInitializeSetting
{
    return YES;
}

-(BOOL)privateInitializeUI
{
    _earthViewController = [[EarthTravelViewController alloc] init];
    _earthViewController.view.frame = CGRectMake(0,
                                                 0,
                                                 [UIScreen mainScreen].bounds.size.width,
                                                 [UIScreen mainScreen].bounds.size.height);
    [_earthViewController initialize];
    [self.view addSubview:_earthViewController.view];
    
    // btn
    {
        if (!_btnRecord) {
            _btnRecord = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.view addSubview:_btnRecord];
        }
        [_btnRecord setTitle:@"Record" forState:UIControlStateNormal];
        [_btnRecord setTitle:@"Record" forState:UIControlStateHighlighted];
        
        _btnRecord.backgroundColor = [UIColor blackColor];
        _btnRecord.alpha = 0.3;
        
        [_btnRecord setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnRecord setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        _btnRecord.layer.borderWidth = 1.0;
        _btnRecord.layer.borderColor = [UtilManager colorWithHexString:@"dedede"].CGColor;
        
        [_btnRecord addTarget:self action:@selector(selectorRecordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _btnRecord.frame = CGRectMake(10, 30, 200, 30);
        _btnRecord.layer.cornerRadius = 5.0;
    }
    
    // but run
    {
        if (!_btnRun) {
            _btnRun = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.view addSubview:_btnRun];
        }
        [_btnRun setTitle:@"Run Animation" forState:UIControlStateNormal];
        [_btnRun setTitle:@"Run Animation" forState:UIControlStateHighlighted];
        
        _btnRun.backgroundColor = [UIColor blackColor];
        _btnRun.alpha = 0.3;
        
        [_btnRun setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnRun setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        _btnRun.layer.borderWidth = 1.0;
        _btnRun.layer.borderColor = [UtilManager colorWithHexString:@"dedede"].CGColor;
        
        [_btnRun addTarget:self action:@selector(selectorRunButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _btnRun.frame = CGRectMake(10,
                                   _btnRecord.frame.origin.y + _btnRecord.frame.size.height + 10,
                                   200,
                                   30);
        _btnRun.layer.cornerRadius = 5.0;
    }
    
    // btn spin
    {
        if (!_btnSpin) {
            _btnSpin = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.view addSubview:_btnSpin];
        }
        [_btnSpin setTitle:@"Spin Animation" forState:UIControlStateNormal];
        [_btnSpin setTitle:@"Spin Animation" forState:UIControlStateHighlighted];
        
        _btnSpin.backgroundColor = [UIColor blackColor];
        _btnSpin.alpha = 0.3;
        
        [_btnSpin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnSpin setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        _btnSpin.layer.borderWidth = 1.0;
        _btnSpin.layer.borderColor = [UtilManager colorWithHexString:@"dedede"].CGColor;
        
        [_btnSpin addTarget:self action:@selector(selectorSpinButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _btnSpin.frame = CGRectMake(10,
                                   _btnRun.frame.origin.y + _btnRun.frame.size.height + 10,
                                   200,
                                   30);
        _btnSpin.layer.cornerRadius = 5.0;
    }
    return YES;
}

#pragma mark - selectors

-(void)selectorRecordButtonClicked:(id)sender
{
    if (_projectVideo) {
        [_btnRecord setTitle:@"Record" forState:UIControlStateNormal];
        [_btnRecord setTitle:@"Record" forState:UIControlStateHighlighted];
        
        [_projectVideo stopVideoCaptureWithCompletionHandler:^(NSDictionary *info, NSError *error) {
            NSLog(@"path: %@", [info objectForKey:IQFilePathKey]);
            //UISaveVideoAtPathToSavedPhotosAlbum([info objectForKey:IQFilePathKey],nil,nil,nil);
            MPMoviePlayerViewController *controller = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:[info objectForKey:IQFilePathKey]]];
            [self presentMoviePlayerViewControllerAnimated:controller];
        }];
        _projectVideo = nil;
        return;
    }
    [_btnRecord setTitle:@"Stop Record" forState:UIControlStateNormal];
    [_btnRecord setTitle:@"Stop Record" forState:UIControlStateHighlighted];
    _projectVideo = [[IQProjectVideo alloc] initWithView:(SCNView*)_earthViewController.view];
    [_projectVideo startVideoCapture];
}

-(void)selectorRunButtonClicked:(id)sender
{
    if ([[_btnRun titleForState:UIControlStateNormal] isEqualToString:@"Run Animation"]) {
        [_earthViewController runAnimation];
        [_btnRun setTitle:@"Stop Animation" forState:UIControlStateNormal];
        [_btnRun setTitle:@"Stop Animation" forState:UIControlStateHighlighted];
    }
    else {
        [_earthViewController stopAnimation];
        [_btnRun setTitle:@"Run Animation" forState:UIControlStateNormal];
        [_btnRun setTitle:@"Run Animation" forState:UIControlStateHighlighted];
    }
}

-(void)selectorSpinButtonClicked:(id)sender
{
    if ([[_btnSpin titleForState:UIControlStateNormal] isEqualToString:@"Spin Animation"]) {
        [_earthViewController spinAnimation];
        [_btnSpin setTitle:@"Stop Spin Animation" forState:UIControlStateNormal];
        [_btnSpin setTitle:@"Stop Spin Animation" forState:UIControlStateHighlighted];
    }
    else {
        [_earthViewController stopSpinAnimation];
        [_btnSpin setTitle:@"Spin Animation" forState:UIControlStateNormal];
        [_btnSpin setTitle:@"Spin Animation" forState:UIControlStateHighlighted];
    }
}

@end
