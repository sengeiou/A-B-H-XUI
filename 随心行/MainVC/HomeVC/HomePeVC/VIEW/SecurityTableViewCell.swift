//
//  SecurityTableViewCell.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/23.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class SecurityTableViewCell: UITableViewCell {
    @IBOutlet var titLab: UILabel!
    @IBOutlet var subLab: UILabel!
    @IBOutlet var scopeLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
