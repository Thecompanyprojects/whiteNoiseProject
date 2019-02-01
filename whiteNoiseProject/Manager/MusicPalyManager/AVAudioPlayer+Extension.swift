//
//  AVAudioPlayer+Extension.swift
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

import AVKit
import Foundation
// 改进写法【推荐】
struct RuntimeKey {
    static var audioVolume = "LCAVAudioPlayerVolume"
    
    /// ...其他Key声明
}

extension AVAudioPlayer{
    
    @objc func lc_stop(){
        if !self.isPlaying{
            //            printLog("没有播放所以跳过")
            return
        }//如果没播放就跳过
        let displayLink = CADisplayLink.init(target: self, selector: #selector(lc_stopCount(timer:)))
        displayLink.frameInterval  = 2;    //屏幕刷新2次调用一次Selector
        displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    
    
    @objc func lc_play(){
        let vc = self.volume
        objc_setAssociatedObject(self, &RuntimeKey.audioVolume, vc, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        
        self.volume = 0
        if !self.isPlaying{
            self.play()
        }
        
        //        if #available(iOS 10.0, *) {
        //           let cv = objc_getAssociatedObject(self, RuntimeKey.jkKey)
        //            setVolume(cv as! Float, fadeDuration: 5)
        //            return
        //        }
        
        let displayLink = CADisplayLink.init(target: self,
                                             selector: #selector(lc_playCount(timer:)))
        displayLink.frameInterval  = 2;    //屏幕刷新2次调用一次Selector
        displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    @objc fileprivate func lc_playCount(timer:CADisplayLink) {
        //        printLog("Count = \(self.volume),\(self)")
        self.volume = self.volume + 0.04
        guard let cvolume = objc_getAssociatedObject(self, &RuntimeKey.audioVolume) as? Float else{
            printLog("没拿到运行时添加的属性")
            timer.invalidate()
            return
        }
        
        if (self.volume >= cvolume) {
            timer.invalidate() //直接销毁
        }
    }
    
    @objc fileprivate func lc_stopCount(timer:CADisplayLink) {
        //        printLog("Count = \(self.volume),\(self)")
        self.volume = self.volume - 0.05
        if (self.volume <= 0) {
            timer.invalidate() //直接销毁
            self.stop()
        }
    }
}

/*
 @interface AVAudioPlayer (XYTool)
 - (void)lc_stop;
 - (void)lc_play;
 @end
 
 @implementation AVAudioPlayer (XYTool)
 - (void)lc_stop{
 CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self
 selector:@selector(logCount:)];
 displayLink.frameInterval  = 2;    //屏幕刷新2次调用一次Selector
 [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
 }
 - (void)logCount:(CADisplayLink *)timer {
 NSLog(@"Count = %f,%@", self.volume,objc_getAssociatedObject(self, &musicName));
 self.volume = self.volume - 0.05;
 if (self.volume <= 0) {
 [timer invalidate]; //直接销毁
 [self stop];
 }
 }
 - (void)lc_play{
 self.volume = 0;
 if (![self isPlaying]){
 [self play];
 }
 CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self
 selector:@selector(playingVolume:)];
 displayLink.frameInterval  = 2;    //屏幕刷新2次调用一次Selector
 [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
 }
 - (void)playingVolume:(CADisplayLink *)timer {
 NSLog(@"Count = %f,%@", self.volume,objc_getAssociatedObject(self, &musicName));
 self.volume = self.volume + 0.03;
 if (self.volume >= 1) {
 self.volume = 1;
 [timer invalidate]; //直接销毁
 }
 }
 @end
 */
