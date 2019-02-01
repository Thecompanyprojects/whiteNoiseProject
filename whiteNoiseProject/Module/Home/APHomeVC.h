//
//  APHomeViewController.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APBaseVC.h"

@interface APHomeVC : APBaseVC
@property (nonatomic, assign) CGRect startFrame;
@property (nonatomic, copy) void (^selectBlock_tabbar)(NSDictionary* info);
@end


