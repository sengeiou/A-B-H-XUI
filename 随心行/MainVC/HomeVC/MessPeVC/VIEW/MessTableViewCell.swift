//
//  MessTableViewCell.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/7.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class MessTableViewCell: UITableViewCell {

    @IBOutlet weak var headIma: UIImageView!
    @IBOutlet weak var notiLab: UILabel!
    @IBOutlet weak var titLab: UILabel!
    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var messLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        createUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func createUI(){
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.main.scale
        
        headIma.layer.masksToBounds = true
        headIma.layer.cornerRadius = 22
        
        notiLab.layer.masksToBounds = true
        notiLab.layer.cornerRadius = 2
    }
}
