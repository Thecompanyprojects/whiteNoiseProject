//
//  APMusicDownloadDelegate.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APSoundDownloadRequest;
@protocol APMusicDownloadDelegate <NSObject>
@optional
- (void)requestDownloadStart:(APSoundDownloadRequest *)request;
- (void)requestDownloading:(APSoundDownloadRequest *)request;
- (void)requestDownloadPause:(APSoundDownloadRequest *)request;
- (void)requestDownloadCancel:(APSoundDownloadRequest *)request;
- (void)requestDownloadFinish:(APSoundDownloadRequest *)request;
- (void)requestDownloadFaild:(APSoundDownloadRequest *)request aError:(NSError *)error;
@end
