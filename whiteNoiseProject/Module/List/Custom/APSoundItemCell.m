//
//  APSoundItemCell.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APSoundItemCell.h"
#import "APSoundModel.h"
#import "UIImage+Color.h"
#import "APLogTool.h"
#import "APSoundDownloadRequest.h"
#import "APPayManager.h"

#import "UIView+DownloadAnimation.h"

@interface APSoundItemCell () <APMusicDownloadDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *vipTagView;
@property (nonatomic, strong) UILabel *titleLabel;
@end
@implementation APSoundItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)setModel:(APSoundModel *)model {
    _model = model;
    
    if (model.is_vip) {
        if ([APPayManager shareInstance].isVip) {
            self.vipTagView.hidden = YES;
        } else {
            self.vipTagView.hidden = NO;
        }
    } else {
        self.vipTagView.hidden = YES;
    }
    
    self.titleLabel.text = model.name_en;
    
    // 图片处理
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.image_select] placeholderImage:[UIImage imageNamed:@"custom_default"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (!error && image) {
            if (model.is_default) {
                self.imageView.image = image;
            } else {
                if (model.isDownload) {
                    self.imageView.image = [image imageWithTintColor:[kHexColor(0x7B7B7B) colorWithAlphaComponent:1.0]];
                } else {
                    self.imageView.image = [image imageWithTintColor:[kHexColor(0x7B7B7B) colorWithAlphaComponent:0.2]];
                }
            }
        }
    }];
}

- (void)downloadSound {
    APSoundDownloadRequest *downloadRequest = [APSoundDownloadRequest initWithURL:self.model.download_url];
    downloadRequest.delegate = self;
    [downloadRequest startDownload];
    
}

#pragma mark - APMusicDownloadDelegate
- (void)requestDownloadStart:(APSoundDownloadRequest *)request {
    [SVProgressHUD showProgress:0 status:@"downloading..."];
}
- (void)requestDownloading:(APSoundDownloadRequest *)request {
    [SVProgressHUD showProgress:request.progress status:@"downloading..."];
}
- (void)requestDownloadPause:(APSoundDownloadRequest *)request {
    [SVProgressHUD dismiss];
}
- (void)requestDownloadCancel:(APSoundDownloadRequest *)request {
    [SVProgressHUD dismiss];
}
- (void)requestDownloadFinish:(APSoundDownloadRequest *)request {
    
    [SVProgressHUD dismiss];

    [[APLogTool shareManager] addLogKey1:@"custom" key2:@"tone_download" content:@{@"result":@"succ"} userInfo:nil upload:NO];
    if (self.downloadFinished) {
        self.downloadFinished(YES, nil);
    }
}
- (void)requestDownloadFaild:(APSoundDownloadRequest *)request aError:(NSError *)error {
    [[APLogTool shareManager] addLogKey1:@"custom" key2:@"tone_download" content:@{@"result":@"fail",@"message":error.localizedDescription} userInfo:nil upload:NO];
    [request deleteResumeDatat];
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    if (self.downloadFinished) {
        self.downloadFinished(NO, error);
    }
}


- (void)initSubviews {
    
    CGFloat scale_w = [UIScreen mainScreen].bounds.size.width / 375.0;
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"custom_default"];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.imageView];
    [self.imageView.widthAnchor constraintEqualToConstant:50 * scale_w].active = YES;
    [self.imageView.heightAnchor constraintEqualToAnchor:self.imageView.widthAnchor].active = YES;
    [self.imageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.imageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:6].active = YES;
    
    self.vipTagView = [[UIImageView alloc] init];
    self.vipTagView.image = [UIImage imageNamed:@"sound_vip"];
    self.vipTagView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imageView addSubview:self.vipTagView];
    [self.vipTagView.widthAnchor constraintEqualToConstant:15 * scale_w].active = YES;
    [self.vipTagView.heightAnchor constraintEqualToAnchor:self.vipTagView.widthAnchor].active = YES;
    [self.vipTagView.rightAnchor constraintEqualToAnchor:self.imageView.rightAnchor].active = YES;
    [self.vipTagView.bottomAnchor constraintEqualToAnchor:self.imageView.bottomAnchor].active = YES;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:11];
    self.titleLabel.text = @"TextName";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.titleLabel.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:1].active = YES;
    [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:0].active = YES;
}

@end
