//
//  AddLectureFooterCell.m
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "AddLectureFooterCell.h"

#import <Masonry/Masonry.h>

@interface AddLectureFooterCell ()

@property (nonatomic, strong) UIButton *addLectureDetailButton;

@end

@implementation AddLectureFooterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _addLectureDetailButton = [[UIButton alloc] init];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [_addLectureDetailButton setTitle:@"수업 추가" forState:UIControlStateNormal];
    [_addLectureDetailButton addTarget:self.delegate action:@selector(addLectureDetailAction) forControlEvents:UIControlEventTouchUpInside];
    _addLectureDetailButton.backgroundColor = [UIColor lightGrayColor];
    
    [self.contentView addSubview:_addLectureDetailButton];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_addLectureDetailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
}

@end
