//
//  HomeCollectionViewFlowLayout.swift
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

import UIKit

class APHomeFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        let rowCount : CGFloat = 2
        
        var cellMargin : CGFloat = 70 * widthScale
        if UIScreen.main.bounds.size.width > 375{
            cellMargin = 70 * 1.3
        }
        
        let lineSpacing = cellMargin - 10
        
        let topInset = 150 //- (UIDevice.current.isX() ? 88 : 64)
        self.sectionInset = UIEdgeInsets(top: CGFloat(topInset), left: cellMargin, bottom: 0, right: cellMargin);
        
        self.scrollDirection = .vertical
        self.minimumInteritemSpacing = cellMargin
        self.minimumLineSpacing = lineSpacing
        //      self.collectionView?.bounds.width
        let width: CGFloat  = (UIScreen.main.bounds.width - (rowCount)*cellMargin - cellMargin)/rowCount-0.1;
        
        let height : CGFloat = width + (10.0 + 20.0)*heightScale
        
        self.itemSize = CGSize.init(width: width, height: height)
    }
}
