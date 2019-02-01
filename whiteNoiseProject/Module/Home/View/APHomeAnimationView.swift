//
//  APHomeAnimationView.swift
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

import Foundation
import UIKit
@objcMembers
class APHomeAnimationView : UIView {
    
    private var scaleY : CGFloat = 0.95//高度的缩放比例
    
    private var offsetY : CGFloat = -(UIScreen.main.bounds.height * 0.055 / 2)//上下要高出屏幕相应的比例
    
    private var addHeight : CGFloat = UIScreen.main.bounds.height * 0.055//上下要高出屏幕相应的比例
    
    private var animationView = UIImageView(image: #imageLiteral(resourceName: "默认图_Normal"))
    
    private var imageW : CGFloat = 0
    
    
    private let time :NSInteger = 13 //循环一次的时间
    private var isStop : Bool = true;
    
    var beginSetImage : Bool = false{
        didSet{
            let a = ThemeImageManager.shared.getRandom()
            self.image = a
        }
    }
    
    var image:UIImage = UIImage(named: "默认图_Normal")!{
        didSet{
            self.animationView.image = image
            if image.size.width <= image.size.height{
                //animationView.contentMode = .scaleAspectFill
                
                //animationView.contentMode = .scaleAspectFit
                animationView.frame = CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
                return
            }
            
            imageW = image.size.width/image.size.height * UIScreen.main.bounds.height
            
            animationView.frame = CGRect.init(x: 0, y: offsetY, width: imageW, height: ScreenHeight + addHeight)
            animationView.transform = CGAffineTransform.init(scaleX: 1, y: scaleY)
            animationView.layoutSubviews()
        }
    }
    
    func stopAnimation(){
        isStop = true
    }
    
    func beginAnimation(){
        if isStop == false{ return }
        isStop = false
        self.imageLefeMove()
    }
    
    
    func setupUI(){
        
        animationView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        animationView.image = image
        addSubview(animationView)
        //        maskView.frame = animationView.frame
        //        addSubview(maskView)
    }
    
    
    var x1: CGFloat = 0{
        didSet{
            if x1 == ScreenWidth {
                if isStop{return}
                imageLefeMove()
            }
        }
    }
    
    var x2: CGFloat = 0{
        didSet{
            if x2 ==  ScreenWidth {
                if isStop{return}
                imageRightMove()
            }
        }
    }
    
    
    func imageLefeMove(){
        
        UIView.animate(withDuration: TimeInterval(time), delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            let a = (self.ScreenWidth - self.imageW) / 2
            self.animationView.frame = CGRect.init(x: a,
                                                   y: self.offsetY,
                                                   width:  self.imageW,
                                                   height: self.ScreenHeight + self.addHeight)
            
            self.animationView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            
        }) { (isSuccess) in
            UIView.animate(withDuration: TimeInterval(self.time), delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                
                self.animationView.frame = CGRect.init(x: self.ScreenWidth - self.imageW,
                                                       y: self.offsetY,
                                                       width:  self.imageW,
                                                       height: self.ScreenHeight + self.addHeight)
                
                
                self.animationView.transform = CGAffineTransform.init(scaleX: 1, y: self.scaleY)
                
            }, completion: { (isSuccess) in
                self.x2 = self.ScreenWidth
            })
        }
    }
    
    
    func imageRightMove(){
        UIView.animate(withDuration: TimeInterval(time), delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            let a = (self.ScreenWidth - self.imageW) / 2
            self.animationView.frame = CGRect.init(x: a,
                                                   y: self.offsetY,
                                                   width:  self.imageW,
                                                   height: self.ScreenHeight + self.addHeight)
            
            self.animationView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            
        }) { (isSuccess) in
            UIView.animate(withDuration: TimeInterval(self.time), delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                
                self.animationView.frame = CGRect.init(x: 0,
                                                       y: self.offsetY,
                                                       width:  self.imageW,
                                                       height: self.ScreenHeight + self.addHeight)
                self.animationView.transform = CGAffineTransform.init(scaleX: 1, y: self.scaleY)
                
            }, completion: { (isSuccess) in
                self.x1 = self.ScreenWidth
            })
        }
    }
    
    
    let ScreenHeight = UIScreen.main.bounds.size.height
    let ScreenWidth = UIScreen.main.bounds.size.width
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    //MARK:- 将要挂起
    @objc func willResignActive(){
        printLog("将要挂起")
        stopAnimation()
    }
    //
    //    override func willMove(toSuperview newSuperview: UIView?) {
    //        printLog("willMove(toSuperview")
    //    }
    
    //    override func didMoveToSuperview() {
    //         printLog("didMoveToSuperview")
    //         self.beginAnimation()
    //
    //    }
    
    //    override func willMove(toWindow newWindow: UIWindow?) {
    //        printLog("willMove(toWindow")
    //    }
    
    //    override func didMoveToWindow() {
    //        printLog("didMoveToWindow")
    ////        self.beginAnimation()
    //    }
    
    //    override func removeFromSuperview() {
    //        printLog(removeFromSuperview)
    //    }
    
    //MARK:- 回到程序
    @objc func didBecomeActive(){
        printLog("回到程序")
        let vc = getTopViewControllerWithRootViewController()
        
        if let vcc = vc as? MMDrawerController,
            let nav = vcc.centerViewController as? UINavigationController{
            printLog(nav.children)
            if nav.children.count <= 1{
                beginAnimation()
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

