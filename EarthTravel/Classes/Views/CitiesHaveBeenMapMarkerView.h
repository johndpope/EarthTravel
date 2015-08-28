//
//  CitiesHaveBeenMapMarkerView.h
//
//  Created by JungNakCheon on 4/7/15.
//  Copyright (c) 2015 ncjung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CitiesHaveBeenMapMarkerView : UIView

@property (nonatomic, copy) NSString* countryCode;
@property (nonatomic, copy) NSString* countryName;
@property (nonatomic, copy) NSString* cityName;
@property (nonatomic, retain) NSDictionary* dicUserInfo;

-(void)initialize;
-(void)prepareForRelease;

@end
