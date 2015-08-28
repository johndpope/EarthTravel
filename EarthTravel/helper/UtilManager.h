//
//  UtilManager.h
//
//  Created by JungNakCheon on 2013. 11. 7..
//  Copyright (c) 2015 JungNakCheon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UtilManager : NSObject
+(UIColor*)colorWithHexString:(NSString*)hex;
+(UIImage *)pngImageWithMainBundle:(NSString *)_file;
+(UIImage *)imageWithView:(UIView *)view;

// SDFONT
+(UIFont *)getAppleNeoThin: (CGFloat) _size;
+(UIFont *)getAppleNeoLight: (CGFloat) _size;
+(UIFont *)getAppleNeoRegular: (CGFloat) _size;
+(UIFont *)getAppleNeoMedium: (CGFloat) _size;
+(UIFont *)getAppleNeoSemiBold: (CGFloat) _size;
+(UIFont *)getAppleNeoBold: (CGFloat) _size;

@end
