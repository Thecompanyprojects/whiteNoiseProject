//
//  CustomListCell.m
//  Sound
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018年 DDTR. All rights reserved.
//

#import "APCustomSoundListCell.h"
#import "APCustomModel.h"

@interface APCustomSoundListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImageViw;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;


@end
@implementation APCustomSoundListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}

- (void)setModel:(APCustomModel *)model {
    _model = model;
    _titleLabel.text = model.name;
    [_bgImageViw sd_setImageWithURL:[NSURL URLWithString:model.icon_name] placeholderImage:[UIImage imageNamed:@"默认图_Normal"] options:SDWebImageProgressiveDownload];
}


- (IBAction)deleteButtonAction:(UIButton *)sender {
    if (self.deleteAction) {
        self.deleteAction(self.model);
    }
}

@end
