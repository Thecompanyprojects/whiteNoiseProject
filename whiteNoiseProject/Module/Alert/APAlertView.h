//
//  APNoiseAlertView.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AlertCallBack)(NSInteger index);

@interface APAlertView : UIView

@property (nonatomic, strong) AlertCallBack callBackBlock;

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title subTitle:(NSString *)subTitle array:(NSArray *)array;

@end
