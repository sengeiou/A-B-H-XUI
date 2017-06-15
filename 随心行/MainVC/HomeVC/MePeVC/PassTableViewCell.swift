//
//  PassTableViewCell.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/13.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class PassTableViewCell: UITableViewCell,UITextFieldDelegate {

//    typealias <#type name#> = <#type expression#>
    
    @IBOutlet weak var titLab: UILabel!
    @IBOutlet weak var passFiled: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        passFiled.delegate = self
        passFiled.clearButtonMode = .whileEditing //解决输入状态下文字下移问题
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passFiled.resignFirstResponder()
        return true
    }
}
