//
//  UITextView+Placeholder.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "UITextView+Placeholder.h"
#import "NSObject+Swizzling.h"


static const char YG_TEXTVIEW_PLACEHOLDERLABEL_KEY;

@implementation UITextView (Placeholder)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self class] yg_swizzlingInstanceMethod:@selector(setFont:) withMethod:@selector(yg_setFont:)];
        [[self class] yg_swizzlingInstanceMethod:@selector(initWithFrame:) withMethod:@selector(yg_initWithFrame:)];
        [[self class] yg_swizzlingInstanceMethod:@selector(initWithCoder:) withMethod:@selector(yg_initWithCoder:)];
    });
}

- (void)yg_setFont:(UIFont *)font {
    [self yg_setFont:font];
    self.yg_placeholderLabel.font = font;
}

- (instancetype)yg_initWithCoder:(NSCoder *)aDecoder {
    [self yg_initWithCoder:aDecoder];
    self.yg_placeholderLabel = [[UILabel alloc] init];
    self.yg_placeholderLabel.text = @"";
    self.yg_placeholderLabel.numberOfLines = 0;
    self.yg_placeholderLabel.textColor = [UIColor lightGrayColor];
    [self.yg_placeholderLabel sizeToFit];
    self.yg_placeholderLabel.font = self.font;
    [self addSubview:self.yg_placeholderLabel];
    [self setValue:self.yg_placeholderLabel forKey:@"_placeholderLabel"];
    
    
    // 文字大小的屏幕适配
    CGFloat pt = self.font.pointSize;
    self.font = [self.font fontWithSize:pt];
    
    
    return self;
}

- (instancetype)yg_initWithFrame:(CGRect)frame {
    [self yg_initWithFrame:frame];
    self.yg_placeholderLabel = [[UILabel alloc] init];
    self.yg_placeholderLabel.text = @"";
    self.yg_placeholderLabel.numberOfLines = 0;
    self.yg_placeholderLabel.textColor = [UIColor lightGrayColor];
    [self.yg_placeholderLabel sizeToFit];
    
    // 代码自定义UITextView时一定要设置字体大小一致,否则会有偏移
    self.font = [UIFont systemFontOfSize:13];
    self.yg_placeholderLabel.font = [UIFont systemFontOfSize:13];
    
    [self addSubview:self.yg_placeholderLabel];
    [self setValue:self.yg_placeholderLabel forKey:@"_placeholderLabel"];
    return self;
}

- (UILabel *)yg_placeholderLabel {
    return objc_getAssociatedObject(self, &YG_TEXTVIEW_PLACEHOLDERLABEL_KEY);
}

- (void)setYg_placeholderLabel:(UILabel *)yg_placeholderLabel {
    objc_setAssociatedObject(self, &YG_TEXTVIEW_PLACEHOLDERLABEL_KEY, yg_placeholderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}





// 利用下面的运行时方法可以发现UITextView 有一个placeholderLabel私有属性,所示上面可以采用KVO来增加一个
//    unsigned int count = 0;
//    Ivar *ivars = class_copyIvarList([UITextView class], &count);
//
//    for (int i = 0; i < count; i++) {
//        Ivar ivar = ivars[i];
//        const char *name = ivar_getName(ivar);
//        NSString *objcName = [NSString stringWithUTF8String:name];
//        NSLog(@"%d : %@",i,objcName);



@end
