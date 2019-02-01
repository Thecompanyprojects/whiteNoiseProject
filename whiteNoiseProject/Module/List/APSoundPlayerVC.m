//
//  APSoundPlayerViewController.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "APSoundPlayerVC.h"

#import "APCustomListVC.h"

#import "MusicInfo.h"       // 一般单首音效
#import "APCustomModel.h"     // 自定义音效
#import "APCustomCardView.h"  // 音效选择
#import "APCuntomTool.h"
#import "APSoundDownloadRequest.h"
#import "APTextAlertView.h"

#import "APCustomListVC.h"


@interface APSoundPlayerVC ()<APMusicDownloadDelegate,MusicPlayerCircleViewDelegate>{
    BOOL isResumePlay;//记录当前音乐是不是暂停状态
    BOOL isFirstShow;//第一次进入界面为true 。播放后置false
}
@property (nonatomic, strong) MusicPlayerCircleView *circleView;

@property (nonatomic, strong) APCustomCardView *customView;
@property (nonatomic, strong) MusicInfo *playerModel;
@property (nonatomic, strong) APCustomModel *customModel;
@property (nonatomic, strong) NSMutableArray <APSoundClassModel *>*soundClassDataArray;

@property (nonatomic, assign) BOOL isSelect;

///记录展示次数
@property (nonatomic, assign) NSInteger showCount;

@end

@implementation APSoundPlayerVC

- (UIStatusBarStyle)preferredStatusBarStyle{
    return  UIStatusBarStyleLightContent;
}

- (instancetype)initWithModel:(MusicInfo *)model{
    self = [super init];
    if (self) {
        _playerModel = model;
        isResumePlay = false;
    }
    return self;
}

- (instancetype)initWithSoundClassDataArray:(NSArray<APSoundClassModel *> *)soundClassDataArray cuntormDataModel:(APCustomModel *)cuntormDataModel isSelect:(BOOL)isSelect {
    self = [super init];
    if (self) {
        _soundClassDataArray = [NSMutableArray arrayWithArray:soundClassDataArray];
        _customModel = cuntormDataModel;
        _isSelect = isSelect;
        
        if (isSelect) {
            [SVProgressHUD show];
        }
        
        isResumePlay = false;
        
        if (isSelect) {
            
        } else {
            for (APSoundClassModel *classModel in soundClassDataArray) {
                for (APSoundModel *sound in classModel.resource) {
                    sound.is_default = NO;
                    for (APSoundModel *sound_ in self.customModel.sounds) {
                        if ([sound.groupId isEqualToNumber:sound_.groupId] && [sound.soundId isEqualToNumber:sound_.soundId]) {
                            sound.is_default = YES;
                        }
                    }
                }
            }
        }
        
        @weakify(self);
        _customView = [[APCustomCardView alloc] initWithCustomSourceDataArray:_soundClassDataArray customDataModel:_customModel addSoundBlock:^(APSoundModel *model) {// 添加音效
            @strongify(self);
            [[APAudioPlayerTools shared] playMusicFor:model];
            self.circleView.APCustomModel = self.customModel;
            
        } deleteSoundBlock:^(APSoundModel *model) { // 删除音效
            @strongify(self);
            [[APAudioPlayerTools shared] stopForModel:model];
            self.circleView.APCustomModel = self.customModel;
            
        } volumeChangedBlock:^(APSoundModel *model) {// 音量改变
            [[APAudioPlayerTools shared] adjustVolume:model.volume WithlModel:model];
            
        } confirmBlock:^(APCustomModel *model) { // 确认
            @strongify(self);
            self.circleView.APCustomModel = model;
        }];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    isFirstShow = true;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.circleView.frame = self.view.bounds;
    [self.view addSubview:self.circleView];
    
    if (self.playerModel) { // 单个音效
        
        self.title = self.playerModel.name;
        self.circleView.playModel = self.playerModel;
        
    } else { // 组合音效
        self.title = self.customModel.name?:@"Custom";
        
        self.circleView.APCustomModel = self.customModel;
    }
    
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"MusicPlayerViewControllerCount"];
    _showCount = count ? count : 0;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupLockScreenInfo) name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lockScreenOperate:)
                                                 name:@"NotifLockScreenCenterOperate"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    APBaseNavVC *nav = (APBaseNavVC *)self.navigationController;
    [nav ap_whiteTitleStyle];
    
    [self.circleView beginAnimation];
    if(isFirstShow){
        isFirstShow = false;
        if (self.playerModel) { // 单个音效
            [self musicDownloadAction];
            if (self.playerModel.mp3FileName != nil && self.playerModel.mp3FileName.length > 0){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.circleView play];
                });
            }
        } else { // 组合音效
            [self.circleView play];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isSelect) {
        // 自定义弹窗
        [self.customView showCuntomSelectView];
        [SVProgressHUD dismiss];
    }
    
    [self setupLockScreenInfo];
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _showCount = _showCount + 1;
    [[NSUserDefaults standardUserDefaults]setInteger:_showCount forKey:@"MusicPlayerViewControllerCount"];
    [self.circleView endAnimation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//MARK:- view的delegate
- (void)musicPlayerViewClikcPlayBtnWithIsPlay:(BOOL)isPlay {
    if (isPlay){//播放
        NSLog(@"点击了播放");
        if (self.playerModel) {
            if (isResumePlay){
                [[APAudioPlayerTools shared] resumePlay];
                NSInteger timeLeft = [[APAudioPlayerTools shared]getTimeLeft];
                if (timeLeft <= 0){
                    [[APAudioPlayerTools shared] configCountDown:30*60];
                    [[APAudioPlayerTools shared] beginTimer];
                }
                isResumePlay = false;
            }else{
                [[APAudioPlayerTools shared] playMusicFor:self.playerModel];
            }
        }
        if (self.customModel) {
            if (isResumePlay){
                [[APAudioPlayerTools shared] resumePlay];
                isResumePlay = false;
            }else{
                [[APAudioPlayerTools shared] playMusicForArr:self.customModel.sounds];
            }
        }
    }else{//暂停
        NSLog(@"点击了暂停");
        [[APAudioPlayerTools shared] pauseMusic];
        isResumePlay = true;
    }
}

- (void)musicPlayerViewClikcRestartTask{//重启下载
    if (self.playerModel && !self.playerModel.isDownloading){
        [self musicDownloadAction];
    }
}

- (void)musicPlayerViewClikcLikeBtn {
    [self saveCustomData];
    NSLog(@"点击了收藏按钮");
}
- (void)musicPlayerViewClikcSoundsBtn {
    NSLog(@"点击了音效按钮");
    [self editAgain];
    
}

- (void)lockScreenOperate:(NSNotification *)notif{
    
    UIEvent *event = notif.userInfo[@"event"];
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:{ // 播放
            NSLog(@"锁屏界面点击播放")
            [self.circleView playUI];
            MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
            NSMutableDictionary *playingInfo = playingInfoCenter.nowPlayingInfo.mutableCopy;
            [playingInfo setObject:@(1) forKey:MPNowPlayingInfoPropertyPlaybackRate];
            playingInfoCenter.nowPlayingInfo = playingInfo;
            
            [playingInfo setObject:@([[APAudioPlayerTools shared] getCountDown]) forKey:MPMediaItemPropertyPlaybackDuration];
            playingInfoCenter.nowPlayingInfo = playingInfo;
        }
            break;
        case UIEventSubtypeRemoteControlPause:{
            NSLog(@"锁屏界面点击暂停")
            [self.circleView stopUI];
            
            // 1.获取锁屏界面中心
            MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
            // 2.设置展示的信息
            NSMutableDictionary *playingInfo = playingInfoCenter.nowPlayingInfo.mutableCopy;
            [playingInfo setObject:@(0) forKey:MPNowPlayingInfoPropertyPlaybackRate];
            playingInfoCenter.nowPlayingInfo = playingInfo;
        }
            break;
        case UIEventSubtypeRemoteControlStop: // 暂停
            NSLog(@"锁屏界面点击停止")
            //            [self playOrPause]; // 控制播放与暂停
            break;
        case UIEventSubtypeRemoteControlNextTrack: // 下一首
            NSLog(@"锁屏界面点击下一首")
            //            [self next]; // 控制播放下一首
            break;
        case UIEventSubtypeRemoteControlPreviousTrack: // 上一首
            NSLog(@"锁屏界面点击上一首")
            //            [self previous]; // 控制播放上一首
            break;
            //            UIEventSubtypeRemoteControlTogglePlayPause
            //
            //            UIEventSubtypeRemoteControlBeginSeekingBackward
            //            UIEventSubtypeRemoteControlEndSeekingBackward
            //            UIEventSubtypeRemoteControlBeginSeekingForward
            //            UIEventSubtypeRemoteControlEndSeekingForward
            
        default:
            break;
    }
}
//MARK:- 设置音乐锁屏界面信息
- (void)setupLockScreenInfo
{
    // 0.获取当前正在播放的歌曲
    
    //    LXFMusic *playingMusic = [LXFMusicTool playingMusic];
    NSString *name = @"";
    NSString *imageName = @"";
    
    if (self.playerModel){
        name = self.playerModel.name;
        imageName = self.playerModel.imageUrl;
    }
    if (self.customModel){
        name = self.customModel.name;
        imageName = self.customModel.icon_name;
    }
    
    
    // 1.获取锁屏界面中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    // 2.设置展示的信息
    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionary];
    // 设置歌曲标题
    [playingInfo setObject:name forKey:MPMediaItemPropertyTitle];
    // app名称
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    [playingInfo setObject:app_Name forKey:MPMediaItemPropertyAlbumTitle];
    // 设置封面
    [[UIImageView new] sd_setImageWithURL:[NSURL URLWithString:imageName] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image != nil){
            MPMediaItemArtwork *artWork =  [[MPMediaItemArtwork alloc] initWithImage:image];
            [playingInfo setObject:artWork forKey:MPMediaItemPropertyArtwork];
        }
    }];
    
    // 设置歌曲播放的总时长
    
    [playingInfo setObject:@([[APAudioPlayerTools shared] getCountDown]) forKey:MPMediaItemPropertyPlaybackDuration];
    
    playingInfoCenter.nowPlayingInfo = playingInfo;
    
    // 3.让应用程序可以接受远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}


//MARK:- 音乐下载delegate
- (void)musicDownloadAction {
    if (self.playerModel.mp3FileName.length > 0){return;}
    
    APSoundDownloadRequest *downloadRequest = [APSoundDownloadRequest initWithURL:self.playerModel.downloadUrl];
    downloadRequest.allowResume = YES;
    downloadRequest.delegate = self;
    if (!self.playerModel.isDownloading) {
        self.circleView.progess = downloadRequest.progress;
        [downloadRequest startDownload];
    }
    self.playerModel.isDownloading = true;
}

- (void)requestDownloadStart:(APSoundDownloadRequest *)request{
    self.playerModel.isDownloading = YES;
    //      [[APLogManager shareManager] addLogKey1:@"music" key2:@"download" content:@{@"state":@"start", @"music_name":self.playerModel.name_en} userInfo:nil upload:NO];
}

- (void)requestDownloading:(APSoundDownloadRequest *)request{
    NSLog(@"%.0f",request.progress*100);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.circleView.progess = request.progress;
    });
}
- (void)requestDownloadPause:(APSoundDownloadRequest *)request{
    //    [[APLogManager shareManager] addLogKey1:@"music" key2:@"download" content:@{@"state":@"pause", @"music_name":self.playerModel.name_en} userInfo:nil upload:NO];
}
- (void)requestDownloadCancel:(APSoundDownloadRequest *)request{
    //    [[APLogManager shareManager] addLogKey1:@"music" key2:@"download" content:@{@"state":@"cancel", @"music_name":self.playerModel.name_en} userInfo:nil upload:NO];
}
- (void)requestDownloadFinish:(APSoundDownloadRequest *)request{
    [[APLogTool shareManager] addLogKey1:@"music" key2:@"download" content:@{@"result":@"succ", @"music_name":self.playerModel.name_en} userInfo:nil upload:NO];
    self.playerModel.mp3FileName = request.saveFileName;
    self.playerModel.isDownloading = NO;
    self.circleView.isDownLoadFinish = true;
}

- (void)requestDownloadFaild:(APSoundDownloadRequest *)request aError:(NSError *)error{
    [[APLogTool shareManager] addLogKey1:@"music" key2:@"download" content:@{@"result":@"fail", @"music_name":self.playerModel.name_en, @"code":@(error.code), @"message":error.localizedDescription?:@""} userInfo:nil upload:NO];
    request.progress = 0;
    self.playerModel.isDownloading = NO;
    self.circleView.isDownLoadFinish = false;
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Download error!", nil)];
}

//MARK:- lazy
- (MusicPlayerCircleView *)circleView{
    if (!_circleView){
        UINib *nib = [UINib nibWithNibName:@"MusicPlayerCircleView" bundle:nil];
        NSArray *objs = [nib instantiateWithOwner:nil options:nil];
        _circleView = objs.firstObject;
        _circleView.delegate = self;
    }
    return _circleView;
}


- (BOOL)ap_backScreenGestureShouldEnabled {
    if (self.playerModel || self.customModel.isSaved) {
        return YES;
    }
    
    return NO;
}


- (void)ap_navigationBarBackButtonItemActionHandle {
    if (!self.playerModel) { // 自定义音乐
        if (!self.customModel.isSaved) {
            [UIAlertController showAlertTitle:@"Tips" message:@"You haven't saved your changes. \nAre you sure you want to quit?" cancelTitle:@"Exit" otherTitle:@"Save" cancleBlock:^{
                [super ap_navigationBarBackButtonItemActionHandle];
            } otherBlock:^{
                [self saveCustomData];
            }];
        } else {
            [super ap_navigationBarBackButtonItemActionHandle];
        }
    } else {
        [super ap_navigationBarBackButtonItemActionHandle];
    }
}


#pragma mark saveCustomData
- (void)saveCustomData {
  
    @weakify(self);
    [APTextAlertView showSaveAlertViewWithComplete:^(NSString *text) {
        @strongify(self);
        
        NSArray <APClassModel *>* classModelArr = [[APSQLiteManager shared] getClassesModels];
        NSArray <MusicInfo *>* musicModelArr = [[APSQLiteManager shared] getMusicListFromType:classModelArr[arc4random_uniform((int)(classModelArr.count))]];
        MusicInfo *music = musicModelArr[arc4random_uniform((int)(musicModelArr.count))];
        
        //每次保存都需要复制一份新的进行保存,要不然会覆盖之前的
        APCustomModel *newModel = self.customModel.copy;
        newModel.customId = [[NSDate date] timeIntervalSince1970];
        newModel.name = text;
        newModel.isSaved = YES;
        
        newModel.icon_name = music.imageUrl;
        newModel.icon_bg_name = music.backGroundImageUrl;
        
        self.title = text;
        
        self.customModel = newModel;
        self.circleView.APCustomModel = newModel;
        
        if ([[APCuntomTool sharedCuntomTool] saveCustormData:self.customModel]) {
            [SVProgressHUD showSuccessWithStatus:@"Success!"];
            self.customModel.isSaved = YES;
            
            // 是选择的,遍历导航控制器子控制器
            if (self.isSelect) {
                UINavigationController *navVC = self.navigationController;
                BOOL shouldInsertListVC = YES;
                for (APBaseVC *vc in navVC.viewControllers) {
                    if ([vc isKindOfClass:[APCustomListVC class]]) {
                        shouldInsertListVC = NO;
                        break;
                    }
                }
                
                if (shouldInsertListVC) {
                    APCustomListVC *listVC = [[APCustomListVC alloc] init];
                    NSMutableArray *arrM = [NSMutableArray arrayWithArray:navVC.viewControllers];
                    [arrM insertObject:listVC atIndex:arrM.count - 1];
                    navVC.viewControllers = arrM.copy;
                }
            }
            
            [[APLogTool shareManager] addLogKey1:@"custom" key2:@"save" content:nil userInfo:nil upload:YES];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        }
    }];
}


#pragma mark - 从新编辑
- (void)editAgain {
    self.customModel.isSaved = NO;
    [_customView showCuntomSelectView];
}

- (void)dealloc{
    NSLog(@"我已释放");
    [[APAudioPlayerTools shared] stopMusic];
    [[APAudioPlayerTools shared] invalidateTimer];
    
}

@end
