//
//  APDownloadPathHelper.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
//
#import "APDownloadPathHelper.h"
#import <CommonCrypto/CommonDigest.h>
@implementation APDownloadPathHelper
+ (void)checkFilePath:(NSString *)path
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if (!(isDir && existed)) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
/**
 * 默认下载临时路径
 **/
+ (NSString *)downloadTmpPath
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [documentPaths objectAtIndex:0];
    NSString *tmpPath = [docsDir stringByAppendingPathComponent:@"MusicDownloadTmpFiles"];
    [APDownloadPathHelper checkFilePath:tmpPath];
    return tmpPath;
}

/**
 * 默认下载路径
 **/
+ (NSString *)downloadPath
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [documentPaths objectAtIndex:0];
    NSString *savePath = [docsDir stringByAppendingPathComponent:@"MusicDownload"];
    [APDownloadPathHelper checkFilePath:savePath];
    return savePath;
}

/**
 * 获取app  tmp 目录
 **/
+ (NSString *)resumeDatatTmpPath
{
    NSString *tmpDir = NSTemporaryDirectory();
    return tmpDir;
}


/**
 * 计算URL的MD5值作为缓存数据文件名
 **/
+ (NSString *)cachedFileNameForKey:(NSString *)key
{
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

+ (NSInteger)getFileSizeFromPath:(NSString *)path{
    
    const char *filePath = [path UTF8String];
    NSInteger fileSizeBytes = 0;
    FILE *fp = fopen(filePath, "r");
    if (fp == NULL){ return fileSizeBytes;}
    
    fseek(fp, 0, SEEK_END);
    fileSizeBytes = ftell(fp);
    fseek(fp, 0, SEEK_SET);
    fclose(fp);
    
    return fileSizeBytes;
}


@end
