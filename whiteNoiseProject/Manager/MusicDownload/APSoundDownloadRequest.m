//
//  APSoundDownloadRequest.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APSoundDownloadRequest.h"
#import "APSoundDownloadManager.h"
#import "APDownloadPathHelper.h"


@interface APSoundDownloadRequest ()
@property (strong, nonatomic,readwrite) NSString *url;
@property (readwrite,nonatomic) NSMutableURLRequest *request;
@property (weak,nonatomic) APSoundDownloadManager *manager;
@property (strong, nonatomic,readwrite) NSData *resumeData;   //断点续传的Data(包含URL)
@end

@implementation APSoundDownloadRequest

- (void)dealloc
{
    CLog(@"dealloc -- APSoundDownloadRequest");
    self.delegate = nil;
    self.url = nil;
    self.request = nil;
    if (_httpMethod) {
        _httpMethod = nil;
    }
    if (_tempPath) {
        _tempPath = nil;
    }
    if (_savePath) {
        _savePath = nil;
    }
    self.saveFileName = nil;
    self.username = nil;
    self.password = nil;
    self.resumeData = nil;
    self.task = nil;
}
- (instancetype)initWithURL:(NSString *)url
{
    self = [super init];
    if (self) {
        self.url = url;
        self.httpMethod = @"GET";
        [self doInit];
    }
    return self;
}

/**
 * 实例化请求对象 已经存在则返回 不存在则创建一个并返回
 **/
+ (APSoundDownloadRequest *)initWithURL:(NSString *)url
{
    APSoundDownloadRequest *request = [[APSoundDownloadManager downloadManagerInstance] requestForURL:url];
    if (!request) {
        request = [[APSoundDownloadRequest alloc] initWithURL:url];
    }
    request.httpMethod = @"GET";
    return request;
}

- (NSURL *)requestUrl
{
    return [NSURL URLWithString:self.url];
}

- (void)setHttpMethod:(NSString *)httpMethod
{
    _httpMethod = httpMethod;
    self.request.HTTPMethod = httpMethod;
}

/**
 *设置请求头 目前暂未实现
 **/
- (void)setHeadInfo
{
    
}


- (void)doInit
{
    self.state = APSoundDownloadRequestState_None;
    self.manager = [APSoundDownloadManager downloadManagerInstance];
    self.request = [NSMutableURLRequest requestWithURL:[self requestUrl]];
    self.request.cachePolicy = NSURLRequestReloadRevalidatingCacheData;
    //    self.request.timeoutInterval = 60;
    self.request.HTTPMethod = self.httpMethod;
    self.allowResume = NO;
    self.resumeData = [self readResumeData];
    [self setHeadInfo];
}

/**
 * 读取本地保存的文件下载断点位置信息数据
 **/
- (NSData *)readResumeData
{
    NSString *resumeDataPath = [[APDownloadPathHelper resumeDatatTmpPath] stringByAppendingPathComponent:[APDownloadPathHelper cachedFileNameForKey:self.url]];
    NSData *resume_Data = [NSData dataWithContentsOfFile:resumeDataPath];
    return resume_Data;
}

- (NSString *)tempPath
{
    if (!_tempPath) {
        _tempPath = [APDownloadPathHelper downloadTmpPath];
    }
    return _tempPath;
}

- (NSString *)savePath
{
    if (!_savePath) {
        _savePath = [APDownloadPathHelper downloadPath];
    }
    return _savePath;
}

/**
 *开始下载任务 适用于首次添加下载任务
 **/
- (void)startDownload
{
    [self.manager startRequestTask:self];
}

/**
 * 暂停下载任务
 * 注意初始化时allowResume 属性为YES 否则无效
 **/
- (void)pauseDownload
{
    if (!self.allowResume) {
        CLog(@"MusicDownload ERROR: 当前设置的 allowResume 属性为 不支持断点续传, 如果需要请打开此属性");
        return;
    }
    if (self.state == APSoundDownloadRequestState_Pause) {
        CLog(@"MusicDownload ERROR: 任务暂停失败 因为此任务本身处于暂停状态");
        return;
    }
    __weak typeof(self) wself = self;
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        // resumeData : 包含了继续下载的开始位置\下载的url
        wself.resumeData = resumeData;
        wself.task = nil;
        [wself.manager pauseRequest:wself];
        [wself resumeDatatWriteToFile];
    }];
    
}

//断点缓存数据写入文件
- (void)resumeDatatWriteToFile
{
    if (!self.resumeData) {
        CLog(@"ERROR resumeData 为空");
        return;
    }
    NSString *tmpPath = [[APDownloadPathHelper resumeDatatTmpPath] stringByAppendingPathComponent:[APDownloadPathHelper cachedFileNameForKey:self.url]];
    if (![self.resumeData writeToFile:tmpPath atomically:NO]) {
        CLog(@"ERROR resumeData 缓存数据写入失败");
    }
}

//移除断点缓存数据
- (void)deleteResumeDatat
{
    NSString *tmpPath = [[APDownloadPathHelper resumeDatatTmpPath] stringByAppendingPathComponent:[APDownloadPathHelper cachedFileNameForKey:self.url]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
    }
}
//下载完或者出错后删除Tmp文件
- (void)deleteTmp:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

/**
 * 恢复下载任务
 * 注意初始化时allowResume 属性为YES 否则无效
 **/
- (void)resumeDownload
{
    if (!self.allowResume) {
        CLog(@"MusicDownload ERROR: 当前设置的 allowResume 属性为 不支持断点续传, 如果需要请打开此属性");
        return;
    }
    
    if (self.state != APSoundDownloadRequestState_Pause) {
        CLog(@"MusicDownload ERROR: 任务恢复失败 因为此任务本身处于非暂停状态");
        return;
    }
    [self.manager startRequestTask:self];
    self.resumeData = nil;
}

/**
 * 取消下载任务
 **/
- (void)cancelDownload
{
    if (self.state == APSoundDownloadRequestState_Loading) {
        [self.task cancel];
    }
    [self.manager cancelRequest:self];
}

@end

