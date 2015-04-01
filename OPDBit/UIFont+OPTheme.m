//
//  UIFont+OPTheme.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 21..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "UIFont+OPTheme.h"

@implementation UIFont (OPTheme)

+ (UIFont *)op_primary
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:15];
}

+ (UIFont *)op_secondary
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:12];
}

+ (UIFont *)op_title
{
    return [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:17];
}

@end
