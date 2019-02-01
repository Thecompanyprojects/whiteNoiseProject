//
//  APAudioCountDown.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol APAudioCountDownDelegate <NSObject>

- (void)audioCurrentProgress:(NSInteger)count WithTotalCount:(NSInteger)totalCount;
@end

@interface APAudioCountDown : NSObject

@property (nonatomic, assign) NSInteger countDown;//倒计时总时长

@property (nonatomic, assign) NSInteger timeSpent;//倒计时走过时间

- (void)beginTimer;

- (void)stopTimer;


- (void)invalidate;

/**
 获取剩余时间
 
 @return 获取剩余倒计时时间
 */
- (NSInteger)getTimeLeft;

- (void)setDelegate:(id<APAudioCountDownDelegate>)delegate withCountDown:(NSInteger)countDown;
@end
