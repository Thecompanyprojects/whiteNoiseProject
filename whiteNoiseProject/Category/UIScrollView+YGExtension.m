//
//  UIScrollView+YGExtension.m
//  YGToolProject
//
//  Created by 许亚光 on 2018/11/28.
//  Copyright © 2018 xuyaguang. All rights reserved.
//

#import "UIScrollView+YGExtension.h"
#import <objc/runtime.h>

@implementation UIScrollView (YGExtension)

- (UIImage *)yg_longScreenshot {
    UIImage* image = nil;
    UIGraphicsBeginImageContextWithOptions(self.contentSize, YES, 0.0);
    
    //保存collectionView当前的偏移量
    CGPoint savedContentOffset = self.contentOffset;
    CGRect saveFrame = self.frame;
    
    //将collectionView的偏移量设置为(0,0)
    self.contentOffset = CGPointZero;
    self.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    
    //在当前上下文中渲染出collectionView
    [self.layer renderInContext: UIGraphicsGetCurrentContext()];
    //截取当前上下文生成Image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    //恢复collectionView的偏移量
    self.contentOffset = savedContentOffset;
    self.frame = saveFrame;
    
    UIGraphicsEndImageContext();
    if (image) {
        return image;
    } else {
        return nil;
    }
}

@end




static const void *kClickBlock = @"YGEmptyDataSet_ClickBlock";
static const void *kEmptyText = @"YGEmptyDataSet_EmptyText";
static const void *kOffSet = @"YGEmptyDataSet_Offset";
static const void *kImage = @"YGEmptyDataSet_EmptyImage";

@implementation UIScrollView (YGEmptyDataSet)

- (ClickBlock)clickBlock{
    return objc_getAssociatedObject(self, &kClickBlock);
}

- (void)setClickBlock:(ClickBlock)clickBlock{
    
    objc_setAssociatedObject(self, &kClickBlock, clickBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)emptyText{
    return objc_getAssociatedObject(self, &kEmptyText);
}

- (void)setEmptyText:(NSString *)emptyText{
    objc_setAssociatedObject(self, &kEmptyText, emptyText, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)offset{
    
    NSNumber *number = objc_getAssociatedObject(self, &kOffSet);
    return number.floatValue;
}

- (void)setOffset:(CGFloat)offset{
    
    NSNumber *number = [NSNumber numberWithDouble:offset];
    
    objc_setAssociatedObject(self, &kOffSet, number, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (UIImage *)emptyImage{
    return objc_getAssociatedObject(self, &kImage);
}

- (void)setEmptyImage:(UIImage *)emptyImage{
    objc_setAssociatedObject(self, &kImage, emptyImage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}



- (void)setupEmptyData:(ClickBlock)clickBlock{
    self.clickBlock = clickBlock;
    self.emptyDataSetSource = self;
    if (clickBlock) {
        self.emptyDataSetDelegate = self;
    }
}


- (void)setupEmptyDataText:(NSString *)text tapBlock:(ClickBlock)clickBlock{
    
    self.clickBlock = clickBlock;
    self.emptyText = text;
    
    self.emptyDataSetSource = self;
    if (clickBlock) {
        self.emptyDataSetDelegate = self;
    }
}


- (void)setupEmptyDataText:(NSString *)text verticalOffset:(CGFloat)offset tapBlock:(ClickBlock)clickBlock{
    
    self.emptyText = text;
    self.offset = offset;
    self.clickBlock = clickBlock;
    
    self.emptyDataSetSource = self;
    if (clickBlock) {
        self.emptyDataSetDelegate = self;
    }
}


- (void)setupEmptyDataText:(NSString *)text verticalOffset:(CGFloat)offset emptyImage:(UIImage *)image tapBlock:(ClickBlock)clickBlock{
    
    self.emptyText = text;
    self.offset = offset;
    self.emptyImage = image;
    self.clickBlock = clickBlock;
    
    self.emptyDataSetSource = self;
    if (clickBlock) {
        self.emptyDataSetDelegate = self;
    }
    
}



#pragma mark - DZNEmptyDataSetSource

// 空白界面的标题
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = self.emptyText?:NSLocalizedString(@"没有找到任何数据", nil);
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    paragraph.lineSpacing = 4;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Light" size:14.0f],
                                 NSForegroundColorAttributeName: kHexColor(0xcccccc),
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

// 空白页的图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
    return self.emptyImage?:[UIImage imageNamed:@"img_notfind"];
}

//是否允许滚动，默认NO
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

// 垂直偏移量
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView{
    return self.offset;
}


#pragma mark - DZNEmptyDataSetDelegate

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view{
    if (self.clickBlock) {
        self.clickBlock();
    }
}



@end
