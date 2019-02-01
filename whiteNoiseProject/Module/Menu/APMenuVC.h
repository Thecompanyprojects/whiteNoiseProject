//
//  APMenuViewController.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APBaseVC.h"

@interface APMenuVC : APBaseVC

@property (nonatomic, copy) void (^selectBlock)(NSDictionary* info);

@end


