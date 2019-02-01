//
//  APWebViewController.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APBaseVC.h"

typedef NS_ENUM(NSInteger,WebViewContentType) {
    WebViewContentTypePrivacy,
    WebViewContentTypeTerms
};

@interface APWebVC : APBaseVC

@property (nonatomic, assign) WebViewContentType contentType;

@end
