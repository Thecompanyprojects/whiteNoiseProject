//
//  APHomeCollectionViewCell.swift
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

import UIKit
@objcMembers
class APHomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iCon: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    var model : APClassModel?{
        didSet{
            iCon.image = UIImage(named: model!.classIconUrl)
            name.text = model!.name
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        name.font = preferredFont(size: 17)
        
    }
}
