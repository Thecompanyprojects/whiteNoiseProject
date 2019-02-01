//
//  Common.swift
//  Sound
//
//  Created by 郭连城 on 2018/9/11.
//  Copyright © 2018年 DDTR. All rights reserved.
//

import Foundation
let widthScale = UIScreen.main.bounds.size.width/375
let heightScale = UIScreen.main.bounds.size.height/667

let Kwidth = UIScreen.main.bounds.size.width
let Kheight = UIScreen.main.bounds.size.height



enum UIFontName:String {
    case pingfang_sc_light = "PingFangSC-Light"
    case pingfang_sc_medium = "PingFangSC-Medium"
    
//    family:PingFang SC
//    font:PingFangSC-Medium
//    font:PingFangSC-Semibold
//    font:PingFangSC-Light
//    font:PingFangSC-Ultralight
//    font:PingFangSC-Regular
//    font:PingFangSC-Thin
}

/// 全局字体
///
/// - Parameter size:
/// - Returns:
 func preferredFont(size:CGFloat)->UIFont{
    return customFont(size: size, name: UIFontName.pingfang_sc_light)
}

 func customFont(size:CGFloat,name:UIFontName)->UIFont{
    if let font = UIFont(name: name.rawValue, size: size){
        return font
    }else{
        return UIFont.systemFont(ofSize: size)
    }
}
    func traversingFont(){
        for fontfamilyname in UIFont.familyNames
       {
            printLog("↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓")
            printLog("family:\(fontfamilyname)")
            for fontName in UIFont.fontNames(forFamilyName: fontfamilyname){
                printLog("font:\(fontName)")
            }
            printLog("↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\n\n\n\n\n")

        }
}

func getTopViewControllerWithRootViewController() -> UIViewController {
    let mainvc = UIApplication.shared.keyWindow!.rootViewController
    return topViewControllerWithRootViewController(mainvc!)
}

//MARK:- 拿到当前在界面上的控制器
func topViewControllerWithRootViewController(_ rootViewController : UIViewController) -> UIViewController{
    if(rootViewController.isKind(of: UITabBarController.self)){
        let tabBarController = rootViewController as! UITabBarController
        return topViewControllerWithRootViewController(tabBarController.selectedViewController!)
    } else if(rootViewController.isKind(of: UINavigationController.self)) {
        let navigationController = rootViewController as? UINavigationController
        return topViewControllerWithRootViewController((navigationController?.visibleViewController)!)
    } else if ((rootViewController.presentedViewController) != nil) {
        let presentedViewController = rootViewController.presentedViewController
        return topViewControllerWithRootViewController(presentedViewController!)
    } else {
        return rootViewController
    }
}


