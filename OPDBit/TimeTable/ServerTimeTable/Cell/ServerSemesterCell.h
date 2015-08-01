//
//  ServerSemesterCell.h
//  OPDBit
//
//  Created by 1000732 on 2015. 8. 1..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

@class ServerSemesterObject;

#import <UIKit/UIKit.h>

@interface ServerSemesterCell : UITableViewCell

@property (nonatomic, strong) ServerSemesterObject *serverSemester;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
