//
//  APFeedbackEmailFillView.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APFeedbackEmailTextFiled.h"

@interface APFeedbackEmailTextFiled ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation APFeedbackEmailTextFiled

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleLabel.text = NSLocalizedString(@"Email:", nil);
    self.textField.placeholder = NSLocalizedString(@"Optional, Convenient for us to contact you", nil);
    [self.textField addTarget:self action:@selector(textDidChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.textField setValue:kHexColor(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
    
    
}

#pragma mark textDidChanged
- (void)textDidChanged:(UITextField *)sender {
    _email = sender.text;
}


@end
