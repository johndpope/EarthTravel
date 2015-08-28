//
//  EarthTravelViewController.h
//  EarthTravel
//
//  Created by NakCheonJung on 6/26/15.
//  Copyright (c) 2015 ncjung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EarthTravelViewController : UIViewController

-(void)initialize;
-(void)prepareForRelease;

//-(BOOL)hasFullScreenView;

-(void)dropPinsAtLocations:(NSArray *)pinArray;
-(void)runAnimation;
-(void)stopAnimation;
-(void)spinAnimation;
-(void)stopSpinAnimation;
@end
