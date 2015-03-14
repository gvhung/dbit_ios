//
//  AddLectureHeaderCell.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddLectureHeaderCell : UITableViewCell

@property (nonatomic, retain) NSString *lectureName;
@property (nonatomic, retain) NSString *lectureTheme;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
