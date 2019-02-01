//
//  APSoundDownloadManager.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APSoundDownloadManager.h"
#import "APSoundDownloadRequest.h"
#import "APAudioPlayerTools.h"
#import "APSQLiteManager.h"
#import "APSQLiteManager+APTool.h"

@interface FileUtils : NSObject
+ (NSInteger)getFileSizeFromPath:(NSString *)path;
@end
@implementation FileUtils

+ (NSInteger)getFileSizeFromPath:(NSString *)path{
    
    const char *filePath = [path UTF8String];
    NSInteger fileSizeBytes = 0;
    FILE *fp = fopen(filePath, "r");
    if (fp == NULL){ return fileSizeBytes;}
    
    fseek(fp, 0, SEEK_END);
    fileSizeBytes = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    fclose(fp);
    
    return fileSizeBytes;
}
@end


@interface APSoundDownloadManager ()<NSURLSessionDelegate>
@property (strong, nonatomic) dispatch_queue_t downloadQueue;
@property (strong, nonatomic) NSMutableArray *taskList;
@property (strong, nonatomic) NSURLSession *defaultSession;
@end

static APSoundDownloadManager *downloadManager = nil;

@implementation APSoundDownloadManager
+ (APSoundDownloadManager *)downloadManagerInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [[APSoundDownloadManager alloc] init];
    });
    return downloadManager;
}
- (APSoundDownloadRequest *)requestForURL:(NSString *)url
{
    APSoundDownloadRequest *req = nil;
    @synchronized(self){
        for (APSoundDownloadRequest *tmpRequest in self.taskList) {
            if ([tmpRequest.url isEqualToString:url]) {
                req = tmpRequest;
                break;
            }
        }
    }
    return req;
}

- (void)dealloc {
    
    self.downloadQueue = nil;
    [self.taskList removeAllObjects];
    self.taskList = nil;
    self.defaultSession = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self doInit];
    }
    return self;
}
- (void)doInit
{
    self.downloadQueue = dispatch_queue_create("MusicDownloadQueue", DISPATCH_QUEUE_SERIAL);
    self.taskList = [[NSMutableArray alloc] init];
}

- (NSURLSession*) defaultSession {
    
    static dispatch_once_t onceToken;
    static NSURLSessionConfiguration *defaultSessionConfiguration;
    static NSURLSession *defaultSession;
    dispatch_once(&onceToken, ^{
        defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        defaultSessionConfiguration.requestCachePolicy = NSURLRequestReloadRevalidatingCacheData;
        defaultSessionConfiguration.timeoutIntervalForRequest = 20; //给定时间内没有数据传输的超时时间
        //        defaultSessionConfiguration.timeoutIntervalForResource = 60; //给定时间内服务器查找资源超时时间
        defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration
                                                       delegate:self
                                                  delegateQueue:[NSOperationQueue mainQueue]];
    });
    
    return defaultSession;
}


#pragma mark-
#pragma mark- 控制下载队列数量
- (void)refreshDownloadTask
{
    __weak APSoundDownloadManager *wself = self;
    dispatch_async(self.downloadQueue, ^{
        APSoundDownloadManager *sself = wself;
        int startCount = 0;
        BOOL hasTaskRuning = NO;
        for (int i = 0; i < sself.taskList.count; i ++ ) {
            APSoundDownloadRequest *req = [sself.taskList objectAtIndex:i];
            if (req.state == APSoundDownloadRequestState_Loading) {
                startCount ++;
                hasTaskRuning = YES;
            }else if (req.state == APSoundDownloadRequestState_Wait) {
                req.state = APSoundDownloadRequestState_Loading;
                [req.task resume];
                startCount ++;
                hasTaskRuning = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([req.delegate respondsToSelector:@selector(requestDownloadStart:)]) {
                        [req.delegate requestDownloadStart:req];
                    }
                });
            }
            if (startCount >= maxConcurrentTaskCount) {
                break;
            }
        }
#ifdef TARGET_OS_IPHONE
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = hasTaskRuning;
        });
#endif
    });
}

/**
 * 添加下载任务/恢复下载任务
 **/
- (void)updateTaskListRequst:(APSoundDownloadRequest *)request
{
    __weak APSoundDownloadManager *wself = self;
    dispatch_async(self.downloadQueue, ^{
        APSoundDownloadManager *sself = wself;
        if ([sself.taskList containsObject:request]) {
            CLog(@"包含此下载请求..将其调整至任务队列最后");
            APSoundDownloadRequest *tmpRequest = request;
            [sself.taskList removeObject:request];
            [sself.taskList addObject:tmpRequest];
        }else {
            CLog(@"不包含此下载请求..将其加入任务队列中");
            [sself.taskList addObject:request];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([request.delegate respondsToSelector:@selector(requestDownloadStart:)]){
                [request.delegate requestDownloadStart:request];
            }
            [sself refreshDownloadTask];
        });
    });
}

/**
 *移除下载任务 条件如下
 * 1)下载完成
 * 2)下载失败
 **/
- (void)removeTasklistAtRequest:(APSoundDownloadRequest *)request
{
    if (!request) {
        return;
    }
    __weak APSoundDownloadManager *wself = self;
    dispatch_async(self.downloadQueue, ^{
        APSoundDownloadManager *sself = wself;
        [sself.taskList removeObject:request];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sself refreshDownloadTask];
        });
    });
}

- (void)startRequestTask:(APSoundDownloadRequest *)request
{
    if(!request || !request.request) {
        CLog(@"MusicDownload ERROR Request is nil, check your URL and other parameters you use to build your request");
        return;
    }
    NSURLSessionDownloadTask *task = nil;
    if (request.allowResume && request.resumeData) {
        task = [self.defaultSession downloadTaskWithResumeData:request.resumeData];
    }else {
        task = [self.defaultSession downloadTaskWithRequest:request.request];
    }
    request.task = task;
    if (request.state != APSoundDownloadRequestState_Loading){
        request.state = APSoundDownloadRequestState_Wait;
    }
    
    //添加下载任务之前去查看本地是否已下载，如果已经下载，则回调完成
    request.saveFileName = request.url.lastPathComponent;
    NSString *savePath = [request.savePath stringByAppendingPathComponent:request.saveFileName];
    if([[NSFileManager defaultManager]fileExistsAtPath:savePath]){
        CLog(@"已经下载过，回调完成%@",request.savePath);
        [self finishDownload:request];
        return;
    }
    
    [self updateTaskListRequst:request];
}

/**
 * 暂停任务
 **/
- (void)pauseRequest:(APSoundDownloadRequest *)request
{
    request.state = APSoundDownloadRequestState_Pause;
    [self refreshDownloadTask];
    if ([request.delegate respondsToSelector:@selector(requestDownloadPause:)]) {
        [request.delegate requestDownloadPause:request];
    }
}
/**
 *取消下载任务
 **/
- (void)cancelRequest:(APSoundDownloadRequest *)request
{
    request.state = APSoundDownloadRequestState_Cancel;
    [request deleteResumeDatat];
    [self removeTasklistAtRequest:request];
    if ([request.delegate respondsToSelector:@selector(requestDownloadCancel:)]) {
        [request.delegate requestDownloadCancel:request];
    }
}

- (void)finishDownload:(APSoundDownloadRequest *)request{
    
    [[APSQLiteManager shared] saveFileRecord:request.url AndFileName:request.saveFileName];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicDownloadFinishNotification
                                                        object:@{request.url:request.saveFileName}];
    if ([request.delegate respondsToSelector:@selector(requestDownloadFinish:)]) {
        [request.delegate requestDownloadFinish:request];
    }
}
#pragma mark-
#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    __block APSoundDownloadRequest *matchingRequest = nil;
    [self.taskList enumerateObjectsUsingBlock:^(APSoundDownloadRequest *request, NSUInteger idx, BOOL *stop) {
        if([request.task.currentRequest.URL.absoluteString isEqualToString:downloadTask.currentRequest.URL.absoluteString]) {
            matchingRequest = request;
            [request deleteResumeDatat]; //移除断点续传缓存数据文件
            request.savePath = [request.savePath stringByAppendingPathComponent:request.saveFileName];
            NSError *error = nil;
            NSInteger fileSize = [FileUtils getFileSizeFromPath:location.path];
            if(fileSize < 200){
                CLog(@"这个链接可能有问题‘’‘request%@ fileSize:%ld",request.url,(long)fileSize);
            }
            
            if(![[NSFileManager defaultManager] moveItemAtPath:location.path toPath:request.savePath error:&error]) {
                CLog(@"MusicDownload ERROR Failed to save downloaded file at requested path [%@] with error %@/n", request.savePath, error);
                if (error.code == 516){
                    CLog(@"这个链接%@已经下载过了",request.url);
                    [self finishDownload:request];
                }else
                    if ([request.delegate respondsToSelector:@selector(requestDownloadFaild:aError:)]) {
                        [request.delegate requestDownloadFaild:request aError:error];
                    }
            }else {
                [self finishDownload:request];
                
            }
            *stop = YES;
        }
    }];
    
    [self removeTasklistAtRequest:matchingRequest];
}



- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (float)(((float)totalBytesWritten) / ((float)totalBytesExpectedToWrite));
    [self.taskList enumerateObjectsUsingBlock:^(APSoundDownloadRequest *request, NSUInteger idx, BOOL *stop) {
        if([request.task.currentRequest.URL.absoluteString isEqualToString:downloadTask.currentRequest.URL.absoluteString]) {
            if (request.progress > request.progress) {
                CLog(@"MusicDownload ERROR 下载进度异常....");
            }
            if (!request.saveFileName || request.saveFileName.length <= 0) {
                request.saveFileName = downloadTask.response.suggestedFilename;
            }
            request.progress = progress;
            if ([request.delegate respondsToSelector:@selector(requestDownloading:)]) {
                [request.delegate requestDownloading:request];
            }
        }
    }];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    CLog(@"didResumeAtOffset  fileOffset: %lld  expectedTotalBytes: %lld",fileOffset,expectedTotalBytes);
    /**
     * fileOffset：继续下载时，文件的开始位置
     * expectedTotalBytes：剩余的数据总数
     */
}

#pragma mark -
#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    if (error.code == kCFURLErrorCancelled) {
        CLog(@"MusicDownload ERROR 请求取消");
        return;
    }
    __block APSoundDownloadRequest *matchingRequest = nil;
    [self.taskList enumerateObjectsUsingBlock:^(APSoundDownloadRequest *request, NSUInteger idx, BOOL *stop) {
        if([request.task isEqual:task]) {
            matchingRequest = request;
            if(error) {
                CLog(@"MusicDownload ERROR Failed to  downloaded  with error %@", error);
                if ([request.delegate respondsToSelector:@selector(requestDownloadFaild:aError:)]) {
                    [request.delegate requestDownloadFaild:request aError:error];
                }
            }else{
                [self finishDownload:request];
            }
            *stop = YES;
        }
    }];
    [self removeTasklistAtRequest:matchingRequest];
}

#pragma mark -
#pragma mark NSURLSession Authentication delegates

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
    __block APSoundDownloadRequest *matchingRequest = nil;
    [self.taskList enumerateObjectsUsingBlock:^(APSoundDownloadRequest *request, NSUInteger idx, BOOL *stop) {
        if([request.task isEqual:task]) {
            matchingRequest = request;
            *stop = YES;
        }
    }];
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] ||
       [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest]){
        
        if([challenge previousFailureCount] == 3) {
            completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
        } else {
            NSURLCredential *credential = [NSURLCredential credentialWithUser:matchingRequest.username
                                                                     password:matchingRequest.password
                                                                  persistence:NSURLCredentialPersistenceNone];
            if(credential) {
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            } else {
                completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
            }
        }
    }
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
}
@end
