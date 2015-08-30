//
//  UIColor+OPTheme.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 21..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "UIColor+OPTheme.h"


@implementation UIColor (OPTheme)

#pragma mark - Primary Color

+ (UIColor *)op_primary
{
    return [self colorWithHexString:@"#FF5724"];
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
    return [self colorWithHexString:@"#000000" alpha:[self alpha8BitToHexString:@"#DE"]];
}

+ (UIColor *)op_textSecondary
{
    return [self colorWithHexString:@"#FFFFFF" alpha:[self alpha8BitToHexString:@"#B2"]];
}

+ (UIColor *)op_textSecondaryDark
{
    return [self colorWithHexString:@"#000000" alpha:[self alpha8BitToHexString:@"#8A"]];
}

+ (UIColor *)op_textDisabled
{
//    return [self colorWithHexString:@"#4C000000"];
    return [self colorWithHexString:@"#FFFFFF" alpha:[self alpha8BitToHexString:@"#4C"]];
}

+ (UIColor *)op_textDisabledDark
{
    return [self colorWithHexString:@"#000000" alpha:[self alpha8BitToHexString:@"#42"]];
}

#pragma mark - Divider Color

+ (UIColor *)op_dividerDark
{
    return [self colorWithHexString:@"#000000" alpha:[self alpha8BitToHexString:@"#1F"]];
}

+ (UIColor *)op_divider
{
    return [self colorWithHexString:@"#FFFFFF" alpha:[self alpha8BitToHexString:@"#1F"]];
}

#pragma mark - Lecture Theme Color

+ (UIColor *)op_lectureTheme:(NSInteger)themeId
{
    switch (themeId) {
        case 0:
            return [self colorWithHexString:@"#F44336"];
            break;
            
        case 1:
            return [self colorWithHexString:@"#E91E63"];
            break;
            
        case 2:
            return [self colorWithHexString:@"#9C27B0"];
            break;
            
        case 3:
            return [self colorWithHexString:@"#673AB7"];
            break;
            
        case 4:
            return [self colorWithHexString:@"#3F51B5"];
            break;
            
        case 5:
            return [self colorWithHexString:@"#2196F3"];
            break;
            
        case 6:
            return [self colorWithHexString:@"#03A9F4"];
            break;
            
        case 7:
            return [self colorWithHexString:@"#00BCD4"];
            break;
            
        case 8:
            return [self colorWithHexString:@"#009688"];
            break;
            
        case 9:
            return [self colorWithHexString:@"#4CAF50"];
            break;
            
        case 10:
            return [self colorWithHexString:@"#8BC34A"];
            break;
            
        case 11:
            return [self colorWithHexString:@"#CDDC39"];
            break;
            
        case 12:
            return [self colorWithHexString:@"#FFEB3B"];
            break;
            
        case 13:
            return [self colorWithHexString:@"#FFC107"];
            break;
            
        case 14:
            return [self colorWithHexString:@"#FF9800"];
            break;
            
        case 15:
            return [self colorWithHexString:@"#FF5722"];
            break;
            
        case 16:
            return [self colorWithHexString:@"#795548"];
            break;
            
        case 17:
            return [self colorWithHexString:@"#9E9E9E"];
            break;
            
        case 18:
            return [self colorWithHexString:@"#607D8B"];
            break;
            
        default:
            return [self whiteColor];
    }
}

+ (UIColor *)op_newLecutre
{
    return [self colorWithHexString:@"#DEDEDE"];
}

#pragma mark - Snack Bar

+ (UIColor *)op_snackBarColor
{
    return [self colorWithHexString:@"#323232"];
}

#pragma mark - Convert

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    return [self colorWithHexString:hexString alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha
{
    if('#' != [hexString characterAtIndex:0])
        hexString = [NSString stringWithFormat:@"#%@", hexString];
    
    // check for string length
    assert(7 == hexString.length || 4 == hexString.length);
    
    // check for 3 character HexStrings
    hexString = [self hexStringTransformFromThreeCharacters:hexString];
    
    NSString *redHex    = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(1, 2)]];
    unsigned redInt = [self hexValueToUnsigned:redHex];
    
    NSString *greenHex  = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(3, 2)]];
    unsigned greenInt = [self hexValueToUnsigned:greenHex];
    
    NSString *blueHex   = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(5, 2)]];
    unsigned blueInt = [self hexValueToUnsigned:blueHex];
    
    UIColor *color = [UIColor colorWith8BitRed:redInt green:greenInt blue:blueInt alpha:alpha];
    
    return color;
}

+ (UIColor *)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue
{
    return [self colorWith8BitRed:red green:green blue:blue alpha:1.0f];
}

+ (UIColor *)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha
{
    UIColor *color = [UIColor colorWithRed:(float)red/255 green:(float)green/255 blue:(float)blue/255 alpha:alpha];
    return color;
}

+ (NSString *)hexStringTransformFromThreeCharacters:(NSString *)hexString
{
    if(hexString.length == 4)
    {
        hexString = [NSString stringWithFormat:@"#%@%@%@%@%@%@",
                     [hexString substringWithRange:NSMakeRange(1, 1)],[hexString substringWithRange:NSMakeRange(1, 1)],
                     [hexString substringWithRange:NSMakeRange(2, 1)],[hexString substringWithRange:NSMakeRange(2, 1)],
                     [hexString substringWithRange:NSMakeRange(3, 1)],[hexString substringWithRange:NSMakeRange(3, 1)]];
    }
    
    return hexString;
}

+ (unsigned)hexValueToUnsigned:(NSString *)hexValue
{
    unsigned value = 0;
    
    NSScanner *hexValueScanner = [NSScanner scannerWithString:hexValue];
    [hexValueScanner scanHexInt:&value];
    
    return value;
}

+ (float)alpha8BitToHexString:(NSString *)hexString
{
    if('#' != [hexString characterAtIndex:0])
        hexString = [NSString stringWithFormat:@"#%@", hexString];
    NSString *alphaHex = [hexString substringWithRange:NSMakeRange(1, 2)];
    unsigned alphaInt = [self hexValueToUnsigned:alphaHex];
    
    return (float)alphaInt/255.0;
}

@end
