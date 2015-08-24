//
//  AddLectureFooterCell.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

@class AddLectureFooterCell;

#import <UIKit/UIKit.h>

@protocol AddLectureFooterCellDelegate <NSObject>

- (void)addLectureFooterCellDidTapped:(AddLectureFooterCell *)addLectureFooterCell;

@end

@interface AddLectureFooterCell : UITableViewCell

@property (nonatomic, weak) id<AddLectureFooterCellDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
