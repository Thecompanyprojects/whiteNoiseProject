//
//  UIViewController+TimeStamp.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (TimeStamp)

@property (nonatomic, copy) NSString *kEnterTimeStamp;    /**< 进入时间 */
@property (nonatomic, copy) NSString *kExitTimeStamp;     /**< 退出时间 */
@property (nonatomic, copy) NSString *kTimeDuration;      /**< 停留时间 */

@property (nonatomic, copy) NSString *kTagString;           /**< 标识 */

@end

NS_ASSUME_NONNULL_END
