//
//  DeviceTableViewCell.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/13.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    typealias didTapSender = (UIButton?) ->Void
    
    @IBOutlet weak var nickLab: UILabel!
    @IBOutlet weak var phoneLab: UILabel!
    @IBOutlet weak var imeiLab: UILabel!
    @IBOutlet weak var butSender: UIButton!
    var tapClosure: didTapSender?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.main.scale
        butSender.layer.masksToBounds = true
        butSender.layer.cornerRadius = 8;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func tapButClosure(closure: didTapSender?) {
        tapClosure = closure
    }
    
    @IBAction func tapSender(_ sender: UIButton) {
        tapClosure?(sender)
    }
}
