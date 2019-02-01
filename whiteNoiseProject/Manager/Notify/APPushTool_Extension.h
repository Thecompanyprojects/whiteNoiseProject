//
//  APPushTool_Extension.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
#import "APPushTool.h"

@interface APPushTool (Extension)
+ (void)registLocalNotificationTitle:(NSString *)title
                            WithBody:(NSString *)subTitle
                            WithBody:(NSString *)body
                      WithIdentifier:(NSString *)identifier;
@end
