//
//  APAudioPlayerToolsBlock.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//


//#ifndef APAudioPlayerToolsBlock_h
//#define APAudioPlayerToolsBlock_h
//
//
//#endif
#import "APAudioPlayerToolsBlock.h"

/* APAudioPlayerToolsBlock_h */

/**
 拿数据的接口回调用
 
 @param modelArray modelArray description
 */
typedef void(^XY_AudioPlayBlock)(NSArray <MusicInfo *>*modelArray);
