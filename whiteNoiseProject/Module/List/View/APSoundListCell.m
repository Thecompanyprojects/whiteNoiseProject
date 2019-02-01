//
//  APSleepCollectionViewCell.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APSoundListCell.h"
#import "APProgressView.h"
#import "APSoundDownloadRequest.h"
#import <Masonry.h>
#import "APPayManager.h"


@interface APSoundListCell () <APMusicDownloadDelegate>

@property (nonatomic, strong) UILabel       *nameL;
@property (nonatomic, strong) UIButton      *cellBtn;
@property (nonatomic, strong) UIImageView   *imageV;
@property (nonatomic, strong) UIImageView   *lockBtn;
@property (nonatomic, strong) APProgressView *progressView;

@end

@implementation APSoundListCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    [self.contentView addSubview:self.imageV];
    [self.contentView addSubview:self.cellBtn];
    [self.contentView addSubview:self.lockBtn];
    [self.contentView addSubview:self.nameL];
    
    
    [self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-10);
        make.top.mas_equalTo(self.contentView).offset(10);
    }];
    
//        self.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.15].CGColor;
//        self.layer.shadowOffset = CGSizeMake(0,0);
//        self.layer.shadowOpacity = 0.5f;
//        self.layer.shadowRadius = 4.f;
//        self.contentView.layer.masksToBounds = YES;
//        self.contentView.layer.cornerRadius = 5*KWIDTH;
}



- (void)setModel:(MusicInfo *)model{
    _model = model;
    
    
    UIColor *color = [UIColor colorWithHexString: model.argb];
    [self.cellBtn setBackgroundColor:color];
    
    self.nameL.text = model.name;
    [self.nameL sizeToFit];
    if (self.nameL.xy_width > 190*KWIDTH) {
        self.nameL.xy_width = 190*KWIDTH;
    }
    self.nameL.center = CGPointMake(self.contentView.xy_width*0.5, self.contentView.xy_height*0.5);
    
    if ([model.imageUrl containsString:@"http"]){
        NSURL *url = [NSURL URLWithString:model.imageUrl];
        [self.imageV sd_setImageWithURL:url placeholderImage:kPlaceholderImage];
    } else {
        [self.imageV setImage:[UIImage imageNamed:model.imageUrl]];
    }
    
    [self.lockBtn setHidden:true];
    
    [self.progressView removeFromSuperview];
    
    if (model.price.floatValue > 0) {
        [self.lockBtn setHidden:model.isPurchased];
        
        [[APPayManager shareInstance]checkSubscriptionStatusComplete:^(BOOL isVip) {
            [self.lockBtn setHidden:isVip];
        }];
    } else {
        [self.lockBtn setHidden:true];
    }
    
    
    
    
    //    // 播放和下载按钮
    //    if (model.mp3FileName && model.mp3FileName.length > 0) {
    //
    //    } else if (model.isDownloading){
    //        [self musicDownloadAction];
    //    }
}


#pragma mark lockBtnAction
- (void)lockBtnAction:(UIButton *)sender {
    if (self.purchaseAction) {
        self.purchaseAction(self.model);
    }
}


#pragma mark progressViewTapAction
- (void)downloadStopTapAction:(UITapGestureRecognizer *)tap {
    APSoundDownloadRequest *downloadRequest = [APSoundDownloadRequest initWithURL:self.model.downloadUrl];
    if (downloadRequest.state == APSoundDownloadRequestState_None) {
        return;
    }
    
    [downloadRequest pauseDownload];
    [UIAlertController showAlertTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Do you want to cancel the download?", nil) cancelTitle:NSLocalizedString(@"No", nil) otherTitle:NSLocalizedString(@"Yes", nil) cancleBlock:^{
        [downloadRequest resumeDownload];
        self.model.isDownloading = YES;
    } otherBlock:^{
        [downloadRequest cancelDownload];
        self.model.isDownloading = NO;
    }];
}


//MARK:- 点击了cell
- (void)clickSelf:(UIButton *)sender{
    
    //    if ((self.model.price.floatValue > 0) && !self.model.isPurchased){ //如果没订阅，先去订阅
    //        if (self.purchaseAction) {
    //            self.purchaseAction(self.model);
    //        }
    //    }else {
    if ([self.delegate respondsToSelector:@selector(sleepCollectionViewDidSelectItem:)]){
        [self.delegate sleepCollectionViewDidSelectItem:self];
    }
    //    }
}



#pragma mark musicDownloadTapAction
- (void)musicDownloadAction {
    
    [self.imageV addSubview:self.progressView];
    APSoundDownloadRequest *downloadRequest = [APSoundDownloadRequest initWithURL:self.model.downloadUrl];
    downloadRequest.allowResume = YES;
    downloadRequest.delegate = self;
    self.progressView.progress = downloadRequest.progress;
    
    if (!self.model.isDownloading) {
        [downloadRequest startDownload];
    }
    self.model.isDownloading = true;
}

- (void)requestDownloadStart:(APSoundDownloadRequest *)request {
    self.model.isDownloading = YES;
}

- (void)requestDownloading:(APSoundDownloadRequest *)request {
    self.progressView.progress = request.progress;
}

- (void)requestDownloadPause:(APSoundDownloadRequest *)request {
    
}

- (void)requestDownloadCancel:(APSoundDownloadRequest *)request {
    self.model.isDownloading = YES;
    [self.progressView removeFromSuperview];
    
}


- (void)requestDownloadFinish:(APSoundDownloadRequest *)request {
    
    [[APLogTool shareManager] addLogKey1:@"download" key2:@"music" content:@{@"state":@"success", @"music_name":self.model.name_en} userInfo:nil upload:NO];
    self.model.mp3FileName = request.saveFileName;
    self.model.isDownloading = NO;
    [self.progressView removeFromSuperview];
}

- (void)requestDownloadFaild:(APSoundDownloadRequest *)request aError:(NSError *)error {
    
    [[APLogTool shareManager] addLogKey1:@"download" key2:@"music" content:@{@"state":@"failed", @"music_name":self.model.name_en, @"code":@(error.code), @"message":error.localizedDescription?:@""} userInfo:nil upload:NO];
    
    [self.progressView removeFromSuperview];
    self.model.isDownloading = NO;
    
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Download error!", nil)];
}


//MARK:- lazy

- (UIButton *)cellBtn {
    if (!_cellBtn) {
        _cellBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_cellBtn addTarget:self action:@selector(clickSelf:) forControlEvents:UIControlEventTouchUpInside];
        _cellBtn.frame = self.imageV.bounds;
    }
    return _cellBtn;
}


- (APProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[APProgressView alloc] initWithFrame:self.imageV.bounds defaultColor:nil progressColor:nil];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadStopTapAction:)];
        [_progressView addGestureRecognizer:tap];
    }
    return _progressView;
}


- (UIImageView *)lockBtn {
    if (!_lockBtn) {
        _lockBtn = [UIImageView new];
        [_lockBtn setImage:[UIImage imageNamed:@"huiyuan icon"]];
    }
    return _lockBtn;
}


- (UIImageView *)imageV{
    if (!_imageV) {
        _imageV = [[UIImageView alloc]init];
        [_imageV setImage:[UIImage imageNamed:@"夏夜"]];
        _imageV.userInteractionEnabled = YES;
        _imageV.frame = CGRectMake(0, 0, self.contentView.xy_width, self.contentView.xy_height);
    }
    return _imageV;
}


- (UILabel *)nameL{
    if (!_nameL) {
        _nameL = [[UILabel alloc]init];
        _nameL.font = FontPingFangL(14);
        _nameL.textColor = [UIColor whiteColor];
        _nameL.text = @"Rainy day";
        [_nameL sizeToFit];
        _nameL.center = CGPointMake(self.contentView.xy_width*0.5, self.contentView.xy_height*0.5);
        _nameL.adjustsFontSizeToFitWidth = YES;
    }
    return _nameL;
}

@end

