//
//  APSoundDownloadRequest.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "APMusicDownloadDelegate.h"
#import "APSoundDownloadConfig.h"
#import "APSoundDownloadManager.h"

typedef enum {
    APSoundDownloadRequestState_None,                                    //仅仅初始化未做任何操作(既未加入任务队列中)
    APSoundDownloadRequestState_Wait,                                    //等待下载已加入任务队列但未开始
    APSoundDownloadRequestState_Loading,                                 //正在下载
    APSoundDownloadRequestState_Pause,                                   //暂停 已存在任务队列中 属于挂起状态
    APSoundDownloadRequestState_Cancel,                                  //取消任务
}APSoundDownloadRequestState;


@interface APSoundDownloadRequest : NSObject
@property (readonly) NSMutableURLRequest *request;                  //请求对象
@property (nonatomic,assign) APSoundDownloadRequestState state;          //请求状态
@property (nonatomic,strong) NSString *httpMethod,                  //请求方式 默认GET
*tempPath,                                                          //临时文件目录 暂未使用
*savePath,                                                          //保存文件路径 默认 Document/MusicDownload/
*saveFileName;                                                      //保存文件名 默认服务器返回的文件名
@property (nonatomic) NSString *username,                           //用户名 暂未想好怎么用
*password;                                                          //密码   暂未想好怎么用
@property (nonatomic,assign) BOOL allowResume;                     //是否支持断点续传 默认NO
@property (nonatomic) NSURLSessionDownloadTask *task;               //下载任务对象
@property (nonatomic,weak) id <APMusicDownloadDelegate>delegate;         //代理
@property (nonatomic,assign) float progress;                       //下载进度 范围0.0~1.0
@property (nonatomic,strong,readonly) NSString *url;               //下载文件的远程地址URL
@property (nonatomic,strong,readonly) NSData *resumeData;          //断点续传的Data(包含URL信息)

/**
 * 实例化请求对象 已经存在则返回 不存在则创建一个并返回
 **/
+ (APSoundDownloadRequest *)initWithURL:(NSString *)url;

/**
 *开始下载任务 适用于首次添加下载任务
 **/
- (void)startDownload;

/**
 * 暂停下载任务
 * 注意初始化时allowResume 属性为YES 否则无效
 **/
- (void)pauseDownload;

/**
 * 恢复下载任务
 * 注意初始化时allowResume 属性为YES 否则无效
 **/
- (void)resumeDownload;

/**
 * 取消下载任务
 **/
- (void)cancelDownload;

/**
 * 移除断点缓存数据
 * 只有allowResume为yes时 暂停下载 才会有断点缓存数据写入文件
 * 当有新的断点数据时会覆盖 文件区分按照下载URL的MD5值作为文件名
 * 注 外部无需使用 如果 allowResume 为YES 会在文件下载成时自动清除
 **/
- (void)deleteResumeDatat;

@end
