//
//  APSoundDownloadManager.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
#import <Foundation/Foundation.h>
@class APSoundDownloadRequest;
@interface APSoundDownloadManager : NSObject
+ (APSoundDownloadManager *)downloadManagerInstance;
- (APSoundDownloadRequest *)requestForURL:(NSString *)url;
- (void)startRequestTask:(APSoundDownloadRequest *)request;
- (void)pauseRequest:(APSoundDownloadRequest *)request;
- (void)cancelRequest:(APSoundDownloadRequest *)request;
@end
