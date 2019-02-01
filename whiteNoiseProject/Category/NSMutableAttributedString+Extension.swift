//
//  NSMutableAttributedString+Extension.swift
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

import UIKit
//import Foundation
extension NSMutableAttributedString {
    
    func appendString(string:String,color:UIColor,font:UIFont){
        let attString = NSMutableAttributedString.init(string: string)
        let range = NSMakeRange(0, string.count)
        
        attString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        attString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        self.append(attString)
    }
    
}
