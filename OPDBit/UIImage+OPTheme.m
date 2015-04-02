//
//  UIImage+OPTheme.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 4. 3..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "UIImage+OPTheme.h"

@implementation UIImage (OPTheme)

+ (UIImage *)op_barButtonImageWithName:(NSString *)name
{
    float resizeWidth = 22.0f;
    float resizeHeight = 22.0f;
    
    UIImage *originImage = [UIImage imageNamed:name];
    UIGraphicsBeginImageContext(CGSizeMake(resizeWidth, resizeHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, resizeHeight);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, resizeWidth, resizeHeight), [originImage CGImage]);
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
