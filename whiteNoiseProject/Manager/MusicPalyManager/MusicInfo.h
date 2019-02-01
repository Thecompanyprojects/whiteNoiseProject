//
//  MusicInfo.h
//  Sound
//
//  Created by 郭连城 on 2018/7/26.
//  Copyright © 2018年 DDTR. All rights reserved.
//
//冥想模型类
#import <Foundation/Foundation.h>
#import "APSQLProtocol.h"
#import "PlayerProtocol.h"
#import <YYModel/YYModel.h>
@interface MusicInfo : NSObject <APSQLProtocol,PlayerModelProtocol,YYModel>
/// 歌曲的id（主键,唯一性）
@property (nonatomic, strong) NSString * ID;
///（0是免费，目前大于0是付费)
@property (nonatomic, assign) NSInteger isCharge;
/// 价格
@property (nonatomic, strong) NSString *price;
/// 是否已经购买
@property (nonatomic, assign) BOOL isPurchased;
/// 内购ID
@property (nonatomic, strong) NSString * productId;
/// 歌曲的index，排序用
@property (nonatomic, assign) NSInteger index;
/// 根据当前语言环境提供语言,不存数据库
@property (nonatomic, strong) NSString * name;
/// 歌曲的中文名称
@property (nonatomic, strong) NSString * name_zh;
/// 歌曲的英文名称
@property (nonatomic, strong) NSString * name_en;
/// 歌曲的图片Url
@property (nonatomic, strong) NSString * imageUrl;
/// 歌曲播放页背景图片Url
@property (nonatomic, strong) NSString * backGroundImageUrl;
/// 音乐服务器下载链接
@property (nonatomic, strong) NSString * downloadUrl;
/// 歌曲的文件名，带后缀
@property (nonatomic, strong) NSString * mp3FileName;
/// 歌曲的时长
@property (nonatomic, strong) NSString * duration;
/// 内容详情
@property (nonatomic, strong) NSString * content;
///是否播放
//@property (nonatomic, assign) BOOL isPlay;
///是否在下载
@property (nonatomic, assign) BOOL isDownloading;
/// ARGB 8位，有透明度
@property (nonatomic, strong) NSString *argb;

///0是睡眠 1是冥想 1111是小音效
@property (nonatomic, assign) NSInteger flag;
///0是歌曲 1是广告
@property (nonatomic, assign) NSInteger type;



/*---------------------自然音效用的属性---------------------------*/
@property (nonatomic, assign) BOOL isSelected; //是否选中
///自然音效用的音量
@property (nonatomic, assign) CGFloat volume;
///自然音效的白图
@property (nonatomic, strong) NSString * flagImage_1;
///自然音效的黑图
@property (nonatomic, strong) NSString * flagImage_2;
/*---------------------自然音效用的属性---------------------------*/
//@property (nonatomic, strong) NSString * blurPicUrl;   // 歌曲的模糊图片Url
//@property (nonatomic, strong) NSString * album;        // 歌曲的专辑
//@property (nonatomic, strong) NSString * singer;       // 歌曲的歌手
//@property (nonatomic, strong) NSString * artists_name; // 歌曲的作者
//@property (nonatomic, strong) NSMutableArray * timeForLyric;  // 时间对应的歌词

@end
