//
//  MessDetailTableViewCell.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/8.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class MessDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var headIma: UIImageView!
    @IBOutlet weak var arcLab: UILabel!
    @IBOutlet weak var messLab: UILabel!
    @IBOutlet weak var cancelBut: UIButton!
    @IBOutlet weak var confimBut: UIButton!
    @IBOutlet weak var handleLasb: UILabel!
    @IBOutlet weak var messImage: UIImageView!
    var messStype: Int!
    @IBOutlet weak var dateLab: UILabel!
    @IBOutlet weak var timeLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        createUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func createUI(){
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.main.scale
        headIma.layer.masksToBounds = true
        headIma.layer.cornerRadius = 50.0/2
        arcLab.layer.masksToBounds = true
        arcLab.layer.cornerRadius = 4
        messImage.image = #imageLiteral(resourceName: "xingzhuang").stretchableImage(withLeftCapWidth: Int(messImage.frame.size.width/CGFloat(2)), topCapHeight: Int(messImage.frame.size.height/CGFloat(2)))
//          messImage.image = #imageLiteral(resourceName: "xingzhuang").resizableImage(withCapInsets: <#T##UIEdgeInsets#>)
    }
    
    override func draw(_ rect: CGRect) {
//        let context = UIGraphicsGetCurrentContext()
//        context?.setFillColor(UIColor.blue.cgColor)
//        context?.setStrokeColor(UIColor.red.cgColor)
//        context?.setLineWidth(1.5)
//        context?.move(to: CGPoint(x: 10, y: 10))
//        context?.addArc(tangent1End: CGPoint(x: 10, y: 30), tangent2End: CGPoint(x: 30, y: 30), radius: 20)
//        context?.addLine(to: CGPoint(x: 20, y: rect.size.height - 10))
//        context?.closePath()
//        context?.drawPath(using: .fillStroke)
        
    }
}
