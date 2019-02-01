//
//  APPayCell.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/25.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface APPayCell : UITableViewCell
@property (nonatomic, copy) NSString *buttonTitle;
@property (nonatomic, copy) void (^payAction)(void); 
@end

NS_ASSUME_NONNULL_END
