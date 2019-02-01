//
//  APSoundListCollectionViewFlowLayout.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APSoundListFlowLayout.h"

@implementation APSoundListFlowLayout
- (void)prepareLayout{
    [super prepareLayout];
    NSInteger rowCount = 2;
    CGFloat cellMargin = 15;
    
    self.sectionInset = UIEdgeInsetsMake(0, cellMargin, 0, cellMargin);
    
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    CGFloat margin = cellMargin;
    
    self.minimumInteritemSpacing = margin;
    
    self.minimumLineSpacing = margin;
    
    CGFloat width = ([UIScreen mainScreen].bounds.size.width- (rowCount+1)*margin)/rowCount;
    
    self.itemSize = CGSizeMake(width, width);
    
}
@end
