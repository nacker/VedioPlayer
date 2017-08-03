//
//  TableViewCell.m
//  播放器
//
//  Created by nacker on 2017/7/31.
//  Copyright © 2017年 nacker. All rights reserved.
//

#import "TableViewCell.h"
#import "Video.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

@interface TableViewCell()

@end

@implementation TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        UIImageView *bgView = [[UIImageView alloc] init];
        bgView.userInteractionEnabled = YES;
        [self.contentView addSubview:bgView];
        self.bgView = bgView;
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self.contentView);
        }];
        
        
        UIButton *playBtn = [[UIButton alloc] init];
        [playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:playBtn];
        self.playBtn = playBtn;
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@80);
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)playBtnClick
{
    NSLog(@"---playBtnClick");
    
    if ([self.delegate respondsToSelector:@selector(tableViewCell:didSelectPlayBtnAtIndexPath:withVideoPlayBtn:)]) {
        [self.delegate tableViewCell:self didSelectPlayBtnAtIndexPath:self.indexPath withVideoPlayBtn:self.playBtn];
    }
}

- (void)setStatus:(Video *)status
{
    _status = status;
    
    [_bgView sd_setImageWithURL:[NSURL URLWithString:status.cover] placeholderImage:nil];
}

+ (NSString *)cellReuseIdentifier{
    return @"TableViewCell";
}
@end
