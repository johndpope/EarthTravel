//
//  CitiesHaveBeenMapMarkerView.m
//
//  Created by JungNakCheon on 4/7/15.
//  Copyright (c) 2015 ncjung. All rights reserved.
//

#import "CitiesHaveBeenMapMarkerView.h"
#import "UtilManager.h"

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

@interface CitiesHaveBeenMapMarkerView()
{
    UIImageView* _viewCountryFlag;
    UILabel* _lblCityName;
    UILabel* _lblCounturyName;
}
@end

@interface CitiesHaveBeenMapMarkerView(CreateMethods)
@end

@interface CitiesHaveBeenMapMarkerView(PrivateMethods)
-(BOOL)privateInitializeSetting;
-(BOOL)privateInitializeUI;
@end

@interface CitiesHaveBeenMapMarkerView(PrivateServerCommunications)
@end

@interface CitiesHaveBeenMapMarkerView(selectors)
@end

@interface CitiesHaveBeenMapMarkerView(IBActions)
@end

@interface CitiesHaveBeenMapMarkerView(ProcessMethod)
@end


/******************************************************************************************
 * Implementation
 ******************************************************************************************/
@implementation CitiesHaveBeenMapMarkerView


#pragma mark - class life cycle

-(id)init
{
    self = [super init];
    if (self) {
        //NSLog(@"CitiesHaveBeenMapMarkerView::INIT");
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(void)prepareForRelease
{
    
}

-(void)dealloc
{
    //NSLog(@"CitiesHaveBeenMapMarkerView::DEALLOC");
}

#pragma mark - operations

-(void)initialize
{
    [self privateInitializeSetting];
    [self privateInitializeUI];
}

#pragma mark - private methods

-(BOOL)privateInitializeSetting
{
    return YES;
}

-(BOOL)privateInitializeUI
{
    BOOL isExist = YES;
    // country
    {
        if (!_viewCountryFlag) {
            _viewCountryFlag = [[UIImageView alloc] init];
            [self addSubview:_viewCountryFlag];
        }
        NSString* strCountryImagePath = [NSString stringWithFormat: @"icon_%@", _countryCode];
        BOOL isDirectory;
        NSString* bundlePath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:strCountryImagePath] stringByAppendingPathExtension:@"png"];
        isExist = [[NSFileManager defaultManager] fileExistsAtPath:bundlePath isDirectory:&isDirectory];
        if (!isExist) {
            _viewCountryFlag.frame = CGRectMake(0, 0, 0, 0);
        }
        else {
            _viewCountryFlag.image = [UtilManager pngImageWithMainBundle:strCountryImagePath];
            _viewCountryFlag.frame = CGRectMake(3, 3, 53, 36);
            
            _viewCountryFlag.layer.borderWidth = 1.0;
            _viewCountryFlag.layer.borderColor = [UtilManager colorWithHexString:@"d5dfe2"].CGColor;
        }
    }
    
    // city name
    {
        if (!_lblCityName) {
            _lblCityName = [[UILabel alloc] init];
            [self addSubview:_lblCityName];
        }
        _lblCityName.text = _cityName;
        _lblCityName.textColor = [UIColor blackColor];
        _lblCityName.font = [UtilManager getAppleNeoMedium:15];
        
        [_lblCityName sizeToFit];
    }
    
    // country name
    {
        if (!_lblCounturyName) {
            _lblCounturyName = [[UILabel alloc] init];
            [self addSubview:_lblCounturyName];
        }
        _lblCounturyName.text = _countryName;
        _lblCounturyName.textColor = [UIColor blackColor];
        _lblCounturyName.font = [UtilManager getAppleNeoLight:15];
        [_lblCounturyName sizeToFit];
    }
    
    
    float totalLabelHeight = _lblCounturyName.frame.size.height + _lblCityName.frame.size.height;
    float totalLabelWidth = 0.0;
    if (_lblCounturyName.frame.size.width > _lblCityName.frame.size.width) {
        totalLabelWidth = _lblCounturyName.frame.size.width;
    }
    else {
        totalLabelWidth = _lblCityName.frame.size.width;
    }
    
    // layout
    if (isExist) {
        self.frame = CGRectMake(0,
                                0,
                                3 + _viewCountryFlag.frame.size.width + 3 + totalLabelWidth + 3,
                                3 + _viewCountryFlag.frame.size.height + 3);
        _viewCountryFlag.frame = CGRectMake(3,
                                            3,
                                            _viewCountryFlag.frame.size.width,
                                            _viewCountryFlag.frame.size.height);
        
        
        _lblCityName.frame = CGRectMake(_viewCountryFlag.frame.origin.x + _viewCountryFlag.frame.size.width + 3,
                                        (self.frame.size.height - totalLabelHeight)/2,
                                        _lblCityName.frame.size.width,
                                        _lblCityName.frame.size.height);
        
        _lblCounturyName.frame = CGRectMake(_viewCountryFlag.frame.origin.x + _viewCountryFlag.frame.size.width + 3,
                                            _lblCityName.frame.origin.y + _lblCityName.frame.size.height,
                                            _lblCounturyName.frame.size.width,
                                            _lblCounturyName.frame.size.height);
    }
    else {
        self.frame = CGRectMake(0,
                                0,
                                3 + totalLabelWidth + 3,
                                3 + totalLabelHeight + 3);
        
        _lblCityName.frame = CGRectMake(3,
                                        3,
                                        _lblCityName.frame.size.width,
                                        _lblCityName.frame.size.height);
        _lblCounturyName.frame = CGRectMake(3,
                                            _lblCityName.frame.origin.y + _lblCityName.frame.size.height,
                                            _lblCounturyName.frame.size.width,
                                            _lblCounturyName.frame.size.height);
        
    }
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 3.0;
    self.layer.masksToBounds = YES;
    
    return YES;
}

@end
