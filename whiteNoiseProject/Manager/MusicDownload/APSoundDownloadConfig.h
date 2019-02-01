//
//  APSoundDownloadConfig.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//


#ifndef __OPTIMIZE__
#define CLog(...) NSLog(__VA_ARGS__)
#else
#define CLog(...) {}
#endif
static NSString *const MusicDownloadFinishNotification = @"MusicDownloadFinishNotification";

//#warning 下载任务并发数...如需要请修改
#define maxConcurrentTaskCount 2 //下载队列并发数
