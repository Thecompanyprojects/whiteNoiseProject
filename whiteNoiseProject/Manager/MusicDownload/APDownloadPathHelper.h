//
//  APDownloadPathHelper.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APDownloadPathHelper : NSObject
+ (NSString *)downloadTmpPath;
+ (NSString *)downloadPath;
+ (NSString *)resumeDatatTmpPath;
+ (NSString *)cachedFileNameForKey:(NSString *)key;
+ (NSInteger)getFileSizeFromPath:(NSString *)path;

@end
