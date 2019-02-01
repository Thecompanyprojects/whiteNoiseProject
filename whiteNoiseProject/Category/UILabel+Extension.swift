//
//  UILabel+Extension.swift
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

import UIKit

extension UILabel {
    
    ///  便利构造函数
    ///
    /// - Parameters:
    ///   - title:
    ///   - fontName: 默认 14 号字
    ///   - textSize:
    ///   - color: color，默认深灰色
    ///   - numberOfLines:
    ///   - textAlignment:
    ///   - alpha: 透明度
    ///参数后面的值是参数的默认值，如果不传递，就使用默认值
    convenience init(title: String="",
                     fontName:String="",
                     textSize: CGFloat = 14,
                     color: UIColor = UIColor.white,
                     numberOfLines: Int = 0,
                     textAlignment:NSTextAlignment = .center,
                     alpha:CGFloat = 1.0) {
        
        self.init()
        text = title
        
        if fontName.isEmpty{
            font = UIFont.systemFont(ofSize: textSize)
        }else{
            font = UIFont(name: fontName, size: textSize)
        }
        
        textColor = color
        self.numberOfLines = numberOfLines
        sizeToFit()
        self.alpha = alpha
        self.textAlignment = textAlignment
    }
}
