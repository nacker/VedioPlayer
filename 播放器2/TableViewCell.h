//
//  TableViewCell.h
//  播放器
//
//  Created by nacker on 2017/7/31.
//  Copyright © 2017年 nacker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Video,TableViewCell;

@protocol TableViewCellDelegate <NSObject>

@optional

- (void)tableViewCell:(TableViewCell *)tableViewCell didSelectPlayBtnAtIndexPath:(NSIndexPath *)indexPath withVideoPlayBtn:(UIButton *)videoPlayBtn;

@end

@interface TableViewCell : UITableViewCell

@property (nonatomic, strong) Video *status;

@property (nonatomic, assign) NSIndexPath *indexPath;


@property (nonatomic, weak) id<TableViewCellDelegate> delegate;


@property (nonatomic, weak) UIImageView *bgView;
@property (nonatomic, weak) UIButton *playBtn;


+ (NSString *)cellReuseIdentifier;

@end
