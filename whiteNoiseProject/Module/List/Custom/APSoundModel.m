//
//  APSoundModel.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
#import "APSoundModel.h"

@implementation APSoundModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.volume = 0.5;
    }
    return self;
}

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper {
    return @{
             @"soundId":@"soundID"
             };
}

- (BOOL)isDownload {
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [documentPaths objectAtIndex:0];
    NSString *savePath = [docsDir stringByAppendingPathComponent:@"MusicDownload"];
    NSString *name = [NSURL URLWithString:self.download_url].lastPathComponent;
    NSString *saveName = [savePath stringByAppendingPathComponent:name];
    return [[NSFileManager defaultManager] fileExistsAtPath:saveName];
}


- (NSString *)mp3FileName {
    return [NSURL URLWithString:self.download_url].lastPathComponent;
}


- (NSString *)name {
    return self.name_en;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    APSoundModel *newModel = [[APSoundModel allocWithZone:zone] init];
    newModel.groupId = self.groupId;
    newModel.soundId = self.soundId;
    newModel.download_url = self.download_url;
    newModel.image_url = self.image_url;
    newModel.image_select = self.image_select;
    newModel.name = self.name;
    newModel.name_en = self.name_en;
    newModel.is_vip = self.is_vip;
    newModel.is_default = self.is_default;
    newModel.isDownload = self.isDownload;
    newModel.mp3FileName = self.mp3FileName;
    newModel.volume = self.volume;
    return newModel;
}

- (id)copyWithZone:(NSZone *)zone {
    APSoundModel *newModel = [[APSoundModel allocWithZone:zone] init];
    newModel.groupId = self.groupId;
    newModel.soundId = self.soundId;
    newModel.download_url = self.download_url;
    newModel.image_url = self.image_url;
    newModel.image_select = self.image_select;
    newModel.name = self.name;
    newModel.name_en = self.name_en;
    newModel.is_vip = self.is_vip;
    newModel.is_default = self.is_default;
    newModel.isDownload = self.isDownload;
    newModel.mp3FileName = self.mp3FileName;
    newModel.volume = self.volume;
    return newModel;
}


@end
