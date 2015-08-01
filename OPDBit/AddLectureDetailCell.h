//
//  AddLectureDetailCell.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

@class AddLectureDetailCell;

#import <UIKit/UIKit.h>

@protocol AddLectureDetailCellDelegate <NSObject>

- (void)addLectureDetailCell:(AddLectureDetailCell *)addLectureDetailCell didChangedLocation:(NSString *)location;
- (void)addLectureDetailCell:(AddLectureDetailCell *)addLectureDetailCell didChangedDay:(NSInteger)day;
- (void)addLectureDetailCellDidTappedTimeStartButton:(AddLectureDetailCell *)addLectureDetailCell;
- (void)addLectureDetailCellDidTappedTimeEndButton:(AddLectureDetailCell *)addLectureDetailCell;

@end

@interface AddLectureDetailCell : UITableViewCell

@property (nonatomic) NSInteger lectureDetailIndex;
@property (nonatomic, strong) NSString *lectureLocation;
@property (nonatomic) NSInteger day;
@property (nonatomic) NSInteger timeStart;
@property (nonatomic) NSInteger timeEnd;

@property (nonatomic, weak) id<AddLectureDetailCellDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
