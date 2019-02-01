//
//  MusicPlayerSoundLayout.swift
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

import UIKit
class MusicPlayerSoundLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        //let rowCount : CGFloat = 3
        let cellMargin : CGFloat = 20
        
        let lineSpacing = cellMargin
        
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.scrollDirection = .horizontal
        self.minimumInteritemSpacing = cellMargin
        self.minimumLineSpacing = lineSpacing
        //      self.collectionView?.bounds.width
        let width: CGFloat  = 40// (UIScreen.main.bounds.width- (rowCount)*cellMargin - 95)/rowCount;
        
        let height : CGFloat = width// + (10.0 + 20.0)*Kheight
        
        self.itemSize = CGSize.init(width: width, height: height)
    }
}

extension UIDevice {
    
    public func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        return false
    }
    
}


