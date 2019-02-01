//
//  NSString+Blowfish.h
//  Sound
//
//  Created by 许亚光 on 2018/8/22.
//  Copyright © 2018年 DDTR. All rights reserved.
//

/*****************************************
 *  BlowFish 使用说明:
 *                  加密模式：ECB
 *                  填充模式：PKCS5Padding
 *                  输出：base64
 *                  字符集：UTF8
 *****************************************/


#import <Foundation/Foundation.h>

@interface NSString (Blowfish)

/** BlowFish 加密:返回的是Base64的字符串 */
- (NSString *)blowFishEncodingWithKey:(NSString *)pkey;

/** BlowFish 解密:需要是Base64的字符串调用,返回的是解密结果 */
- (NSString *)blowFishDecodingWithKey:(NSString *)pkey;

@end
