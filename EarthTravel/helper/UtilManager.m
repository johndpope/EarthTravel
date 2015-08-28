//
//  UtilManager.m
//
//  Created by JungNakCheon on 2013. 11. 7..
//  Copyright (c) 2013 JungNakCheon. All rights reserved.
//

#import "UtilManager.h"

@implementation UtilManager
+(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    // #으로 시작해도 #을 지워준다.
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+(UIImage *)pngImageWithMainBundle:(NSString *)_file
{
    NSString *path = [[NSBundle mainBundle] pathForResource: _file ofType: @"png"];
    UIImage *img = [UIImage imageWithContentsOfFile: path];
    return img;
}

+(UIFont *)getAppleNeoThin: (CGFloat) _size
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-Thin" size: _size];
}

+(UIFont *)getAppleNeoLight: (CGFloat) _size
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-Light" size: _size];
}

+(UIFont *)getAppleNeoRegular: (CGFloat) _size
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size: _size];
}

+(UIFont *)getAppleNeoMedium: (CGFloat) _size
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size: _size];
}

+(UIFont *) getAppleNeoSemiBold: (CGFloat) _size
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size: _size];
}

+(UIFont *)getAppleNeoBold: (CGFloat) _size
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size: _size];
}

+(UIImage *)imageWithView:(UIView *)view
{
    if (!view || [view isKindOfClass:[NSNull class]]) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width, view.frame.size.height), NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1.0, 1.0);
    [view.layer renderInContext:context];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
