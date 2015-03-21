//
//  UIColor+OPTheme.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 21..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "UIColor+OPTheme.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation UIColor (OPTheme)

/*
 colorPrimary : #FF5722 colorPrimaryDark : #E64A19 colorPrimary100 : #FFCCBC
 colorAccent : #FFAB40 colorAccentDark : #FF9100 colorAccent100 : #FFD180
 background : #FFFFFF backgroundDark : #000000
 textColorPrimaryDark : #DE000000 textColorSecondaryDark : #8A000000 textColorDisabledDark : #42000000
 textColorPrimary : #FFFFFF textColorSecondary : #B2FFFFFF textColorDisabled : #4C000000 (v0.1.1) textColorDisabled : #4CFFFFFF
 dividerDark : #1F000000 divider : #1FFFFFFF
 */

#pragma mark - Primary Color

+ (UIColor *)op_primary
{
    return [self colorWithHexString:@"#FF5722"];
}

+ (UIColor *)op_primaryDark
{
    return [self colorWithHexString:@"#E64A19"];
}

+ (UIColor *)op_primary100
{
    return [self colorWithHexString:@"#FFCCBC"];
}

#pragma mark - Accent Color

+ (UIColor *)op_accent
{
    return [self colorWithHexString:@"#FFAB40"];
}

+ (UIColor *)op_accentDark
{
    return [self colorWithHexString:@"#FF9100"];
}

+ (UIColor *)op_accent100
{
    return [self colorWithHexString:@"#FFD180"];
}

#pragma mark - Background Color

+ (UIColor *)op_background
{
    return [self colorWithHexString:@"#FFFFFF"];
}

+ (UIColor *)op_backgroundDark
{
    return [self colorWithHexString:@"#000000"];
}

#pragma mark - text Color

+ (UIColor *)op_textPrimary
{
    return [self colorWithHexString:@"#FFFFFF"];
}

+ (UIColor *)op_textPrimaryDark
{
    return [self colorWithHexString:@"#DE0000"];
}

+ (UIColor *)op_textSecondary
{
    return [self colorWithHexString:@"#B2FFFF"];
}

+ (UIColor *)op_textSecondaryDark
{
    return [self colorWithHexString:@"#8A0000"];
}

+ (UIColor *)op_textDisabled
{
    return [self colorWithHexString:@"#4C0000"];
    //return [self colorWithHexString:@"#4CFFFF"]; (v0.1.1)
}

+ (UIColor *)op_textDisabledDark
{
    return [self colorWithHexString:@"#420000"];
}

#pragma mark - Divider Color

+ (UIColor *)op_dividerDark
{
    return [self colorWithHexString:@"#1F0000"];
}

+ (UIColor *)op_divider
{
    return [self colorWithHexString:@"#1FFFFF"];
}

#pragma mark - Lecture Theme Color

+ (UIColor *)op_lectureTheme:(NSInteger)themeId
{
    return [self colorWithHexString:@""];
}


#pragma mark - Convert

+ (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return UIColorFromRGB(x);
}

@end
