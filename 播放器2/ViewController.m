//
//  ViewController.m
//  播放器2
//
//  Created by nacker on 2017/8/1.
//  Copyright © 2017年 nacker. All rights reserved.
//

#define kScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define kScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

#define homeURL @"http://c.m.163.com/nc/video/home/0-10.html"
#define moreURL @"http://c.m.163.com/nc/video/home/%ld-10.html"
//#define listURL @"http://c.3g.163.com/nc/video/list/%@/y/0-10.html"
//#define listMoreURL @"http://c.3g.163.com/nc/video/list/%@/y/%ld-10.html"

#import "ViewController.h"
#import "Masonry.h"
#import "TableViewCell.h"
#import "MJRefresh.h"
#import "GetVideoDataTools.h"
#import "Video.h"

#import "KYVedioPlayer.h"

@interface ViewController ()<TableViewCellDelegate,UITableViewDelegate,UITableViewDataSource,KYVedioPlayerDelegate>
{
    KYVedioPlayer *vedioPlayer;
    Video *currentVideo;
    NSIndexPath *currentIndexPath;
}

// video数组
@property (nonatomic, strong) NSMutableArray *videoArray;

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation ViewController

#pragma mark - 懒加载代码
- (NSMutableArray *)videoArray
{
    if (_videoArray == nil){
        self.videoArray = [NSMutableArray array];
    }
    return _videoArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"视频";
    
    [self setupTableView];
    
    [self refresh];
}


- (void)setupTableView
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [tableView registerClass:[TableViewCell class] forCellReuseIdentifier:[TableViewCell cellReuseIdentifier]];
}

- (TableViewCell *)currentCell{
    if (currentIndexPath==nil) {
        return nil;
    }
    TableViewCell *currentCell = (TableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    return currentCell;
}


/**
 * 显示 从全屏来当前的cell视频
 **/
-(void)showCellCurrentVedioPlayer{
    
    if (currentVideo != nil &&  currentIndexPath != nil) {
        
        TableViewCell *currentCell = [self currentCell];
        [vedioPlayer removeFromSuperview];
        
        [UIView animateWithDuration:0.5f animations:^{
            vedioPlayer.transform = CGAffineTransformIdentity;
            vedioPlayer.frame = currentCell.bgView.bounds;
            vedioPlayer.playerLayer.frame =  vedioPlayer.bounds;
            [currentCell.bgView addSubview:vedioPlayer];
            [currentCell.bgView bringSubviewToFront:vedioPlayer];
            
            [vedioPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vedioPlayer).with.offset(0);
                make.right.equalTo(vedioPlayer).with.offset(0);
                make.height.mas_equalTo(40);
                make.bottom.equalTo(vedioPlayer).with.offset(0);
            }];
            [vedioPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vedioPlayer).with.offset(0);
                make.right.equalTo(vedioPlayer).with.offset(0);
                make.height.mas_equalTo(40);
                make.top.equalTo(vedioPlayer).with.offset(0);
            }];
            [vedioPlayer.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vedioPlayer.topView).with.offset(45);
                make.right.equalTo(vedioPlayer.topView).with.offset(-45);
                make.center.equalTo(vedioPlayer.topView);
                make.top.equalTo(vedioPlayer.topView).with.offset(0);
            }];
            [vedioPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vedioPlayer).with.offset(5);
                make.height.mas_equalTo(30);
                make.width.mas_equalTo(30);
                make.top.equalTo(vedioPlayer).with.offset(5);
            }];
            [vedioPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(vedioPlayer);
                make.width.equalTo(vedioPlayer);
                make.height.equalTo(@30);
            }];
            
        }completion:^(BOOL finished) {
            vedioPlayer.isFullscreen = NO;
            [self setNeedsStatusBarAppearanceUpdate];
            vedioPlayer.fullScreenBtn.selected = NO;
            
        }];
    }
}



/**
 *  下拉刷新 上拉加载
 */

- (void)refresh{
    __unsafe_unretained UITableView *tableView = self.tableView;
    // 下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [[GetVideoDataTools shareDataTools] getHeardDataWithURL:homeURL HeardValue:^(NSArray *heardArray, NSArray *videoArray) {
            _videoArray = (NSMutableArray *)videoArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [tableView.mj_header endRefreshing];
            });
        }];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    // 上拉刷新
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        NSString *URL = [NSString stringWithFormat:moreURL,self.videoArray.count - self.videoArray.count%10];
        [[GetVideoDataTools shareDataTools] getHeardDataWithURL:URL HeardValue:^(NSArray *heardArray, NSArray *videoArray) {
            [self.videoArray addObjectsFromArray:videoArray];
            [[GetVideoDataTools shareDataTools].dataArray addObjectsFromArray:videoArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [tableView.mj_header endRefreshing];
            });
        }];
        // 结束刷新
        [tableView.mj_footer endRefreshing];
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videoArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TableViewCell cellReuseIdentifier]];
    if (nil==cell)
    {
        cell = [[TableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[TableViewCell cellReuseIdentifier]];
        
    }
    
    Video *status = self.videoArray[indexPath.row];
    cell.indexPath = indexPath;
    cell.status = status;
    cell.playBtn.tag = indexPath.row;
    
    if (cell.delegate == nil) {
        cell.delegate = self;
    }
    
    if (vedioPlayer && vedioPlayer.superview) {
        if (indexPath.row == currentIndexPath.row) {
            [cell.playBtn.superview sendSubviewToBack:cell.playBtn];    //隐藏播放按钮
        }else{
            [cell.playBtn.superview bringSubviewToFront:cell.playBtn];  //显示播放按钮
        }
        NSArray *indexpaths = [tableView indexPathsForVisibleRows];
        if (![indexpaths containsObject:currentIndexPath] && currentIndexPath!=nil) { //复用机制
            
            if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:vedioPlayer]) {
                vedioPlayer.hidden = NO;
            }else{
//                vedioPlayer.hidden = YES;
                [self closeCurrentCellVedioPlayer];
                [cell.playBtn.superview bringSubviewToFront:cell.playBtn];
            }
        }else{
            if ([cell.bgView.subviews containsObject:vedioPlayer]) {  //当滑倒所属当前视频的时候自动播放
                [cell.bgView addSubview:vedioPlayer];
                [vedioPlayer play];
                vedioPlayer.hidden = NO;
            }
            
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}



#pragma mark - TableViewCellDelegate
- (void)tableViewCell:(TableViewCell *)tableViewCell didSelectPlayBtnAtIndexPath:(NSIndexPath *)indexPath withVideoPlayBtn:(UIButton *)videoPlayBtn
{
    Video *video = self.videoArray[indexPath.row];
    
    [self closeCurrentCellVedioPlayer];
    
    
    currentVideo = video;
    currentIndexPath = [NSIndexPath indexPathForRow:videoPlayBtn.tag inSection:0];
    
//    KYNetworkVideoCell *cell =nil;
//    if ([UIDevice currentDevice].systemVersion.floatValue>=8||[UIDevice currentDevice].systemVersion.floatValue<7) {
//        cell = (tableViewCell *)videoPlayBtn.superview.superview;
//        
//    }else{//ios7系统 UITableViewCell上多了一个层级UITableViewCellScrollView
//        cell = (KYNetworkVideoCell *)videoPlayBtn.superview.superview.subviews;
//        
//    }
    
    if (vedioPlayer) {
        [self releasePlayer];
        vedioPlayer = [[KYVedioPlayer alloc]initWithFrame:tableViewCell.bgView.bounds];
        vedioPlayer.delegate = self;
        vedioPlayer.closeBtnStyle = CloseBtnStyleClose;
        vedioPlayer.titleLabel.text = video.title;
        vedioPlayer.URLString = video.mp4_url;
    }else{
        
        vedioPlayer = [[KYVedioPlayer alloc]initWithFrame:tableViewCell.bgView.bounds];
        vedioPlayer.delegate = self;
        vedioPlayer.closeBtnStyle = CloseBtnStyleClose;
        vedioPlayer.titleLabel.text = video.title;
        vedioPlayer.URLString = video.mp4_url;
    }
    
    [tableViewCell.bgView addSubview:vedioPlayer];
    [tableViewCell.bgView bringSubviewToFront:vedioPlayer];
    [tableViewCell.playBtn.superview sendSubviewToBack:tableViewCell.playBtn];
    [self.tableView reloadData];
}

/**
 * 关闭当前cell 中的 视频
 **/
-(void)closeCurrentCellVedioPlayer{
    if (currentVideo != nil &&  currentIndexPath != nil) {
        TableViewCell *currentCell = [self currentCell];
        [currentCell.playBtn.superview bringSubviewToFront:currentCell.playBtn];
        
        [vedioPlayer resetKYVedioPlayer];
        [vedioPlayer removeFromSuperview];
        
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - KYVedioPlayerDelegate 播放器委托方法
//点击播放暂停按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn{
    NSLog(@"[KYVedioPlayer] clickedPlayOrPauseButton ");
}

//点击关闭按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer clickedCloseButton:(UIButton *)closeBtn{
    
    NSLog(@"[KYVedioPlayer] clickedCloseButton ");
    
    if (kyvedioPlayer.isFullscreen == YES) { //点击全屏模式下的关闭按钮
        self.navigationController.navigationBarHidden = NO;
        [self showCellCurrentVedioPlayer];
    }else{
        
        [self closeCurrentCellVedioPlayer];
    }
    
}

//点击全屏按钮代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    NSLog(@"[KYVedioPlayer] clickedFullScreenButton ");
    
    if (fullScreenBtn.isSelected) {//全屏显示
        self.navigationController.navigationBarHidden = YES;
        kyvedioPlayer.isFullscreen = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        [kyvedioPlayer showFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft player:kyvedioPlayer withFatherView:self.view];
    }else{
        self.navigationController.navigationBarHidden = NO;
        [self showCellCurrentVedioPlayer];
        
    }
}

//单击WMPlayer的代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer singleTaped:(UITapGestureRecognizer *)singleTap{
    
    NSLog(@"[KYVedioPlayer] singleTaped ");
}
//双击WMPlayer的代理方法
-(void)kyvedioPlayer:(KYVedioPlayer *)kyvedioPlayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    
    NSLog(@"[KYVedioPlayer] doubleTaped ");
}

///播放状态
//播放失败的代理方法
-(void)kyvedioPlayerFailedPlay:(KYVedioPlayer *)kyvedioPlayer playerStatus:(KYVedioPlayerState)state{
    NSLog(@"[KYVedioPlayer] kyvedioPlayerFailedPlay  播放失败");
}
//准备播放的代理方法
-(void)kyvedioPlayerReadyToPlay:(KYVedioPlayer *)kyvedioPlayer playerStatus:(KYVedioPlayerState)state{
    
    NSLog(@"[KYVedioPlayer] kyvedioPlayerReadyToPlay  准备播放");
}
//播放完毕的代理方法
-(void)kyplayerFinishedPlay:(KYVedioPlayer *)kyvedioPlayer{
    
    NSLog(@"[KYVedioPlayer] kyvedioPlayerReadyToPlay  播放完毕");
    
    [self closeCurrentCellVedioPlayer];
}


/**
 *  注销播放器
 **/
- (void)releasePlayer
{
    [vedioPlayer resetKYVedioPlayer];
    vedioPlayer = nil;
}

- (void)dealloc
{
    [self releasePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"KYNetworkVideoCellPlayVC dealloc");
}
@end
