//
//  APHomeCorrugationView.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APHomeCorrugationView : UIView

@property (nonatomic, strong)   UIImageView *baseImgV;
@property (nonatomic, strong)   UIImageView *imageView;
@property (nonatomic, strong)   UIImage     *originalImage ;


- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color title:(NSString *)title;

@end
