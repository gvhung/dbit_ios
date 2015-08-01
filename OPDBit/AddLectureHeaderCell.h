//
//  AddLectureHeaderCell.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

@class AddLectureHeaderCell;

#import <UIKit/UIKit.h>

@protocol AddLectureHeaderCellDelegate <NSObject>

- (void)addLectureHeaderCell:(AddLectureHeaderCell *)addLectureHeaderCell didChangedName:(NSString *)name;
- (void)addLectureHeaderCell:(AddLectureHeaderCell *)addLectureHeaderCell didChangedTheme:(NSInteger)themeID;

@end

@interface AddLectureHeaderCell : UITableViewCell

@property (nonatomic, strong) NSString *lectureName;
@property (nonatomic) NSInteger lectureTheme;

@property (nonatomic, weak) id<AddLectureHeaderCellDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
