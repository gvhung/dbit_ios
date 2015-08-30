//
//  UIColor+OPTheme.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 21..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (OPTheme)

/// @name   Primary Color

/**
 *  #FF5722
 */
+ (UIColor *)op_primary;

/**
 *  #E64A19
 */

+ (UIColor *)op_primaryDark;

/**
 *  #FFCCBC
 */

+ (UIColor *)op_primary100;

/// @name   Accent Color

/**
 *  #FFAB40
 */

+ (UIColor *)op_accent;

/**
 *  #FF9100
 */

+ (UIColor *)op_accentDark;

/**
 *  #FFDD180
 */

+ (UIColor *)op_accent100;

/// @name   Background Color

/**
 *  #FFFFFF
 */

+ (UIColor *)op_background;

/**
 *  #000000
 */

+ (UIColor *)op_backgroundDark;

/// @name   Text Color

/**
 *  #FFFFFF
 */

+ (UIColor *)op_textPrimary;

/**
 *  #DE000000
 */

+ (UIColor *)op_textPrimaryDark;

/**
 *  #B2FFFFFF
 */

+ (UIColor *)op_textSecondary;

/**
 *  #8A000000
 */

+ (UIColor *)op_textSecondaryDark;

/**
 *  #4C000000
 *  
 *  @warning    #4CFFFFFF   (ealry from v0.1.1)
 */

+ (UIColor *)op_textDisabled;

/**
 *  #42000000
 */

+ (UIColor *)op_textDisabledDark;

/// @name   Divider Color

/**
 *  #1F000000
 */

+ (UIColor *)op_dividerDark;

/**
 *  #1FFFFFFF
 */

+ (UIColor *)op_divider;

/**
 *  Lecture Theme
 */

+ (UIColor *)op_lectureTheme:(NSInteger)themeId;

/**
 *  New Lecture Color
 */

+ (UIColor *)op_newLecutre;

/**
 *  #323232
 */
+ (UIColor *)op_snackBarColor;

@end
