//
//  PhotoCollectionViewCell.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/25.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var selIma: UIImageView!
    var _imaSelect: Bool? = false
    var imaSelect : Bool?{
        set{
            _imaSelect = newValue
            if _imaSelect! {
                selIma.image = UIImage(named: "btn_choose_pre")
            }
            else{
                selIma.image = UIImage(named: "btn_choose")
            }
        }
        get{
            return _imaSelect
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
