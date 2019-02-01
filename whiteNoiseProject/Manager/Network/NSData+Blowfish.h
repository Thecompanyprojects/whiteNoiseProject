//
//  NSData+Blowfish.h
//  Sound
//
//  Created by 许亚光 on 2018/8/31.
//  Copyright © 2018年 DDTR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Blowfish)

/** BlowFish 加密 */
- (NSData *)blowFishEncodingWithKey:(NSString *)pkey;

/** BlowFish 解密 */
- (NSData *)blowFishDecodingWithKey:(NSString *)pkey;


@end
