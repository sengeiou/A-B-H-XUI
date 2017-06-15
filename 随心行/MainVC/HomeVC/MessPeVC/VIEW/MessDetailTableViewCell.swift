//
//  MessDetailTableViewCell.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/8.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class MessDetailTableViewCell: UITableViewCell {

    typealias tapBut = (Int?) ->Void
    
    var tapClosure: tapBut?
    @IBOutlet weak var headIma: UIImageView!
    @IBOutlet weak var arcLab: UILabel!
    @IBOutlet weak var messLab: UILabel!
    @IBOutlet weak var cancelBut: UIButton!
    @IBOutlet weak var confimBut: UIButton!
    @IBOutlet weak var handleLasb: UILabel!
    @IBOutlet weak var messImage: UIImageView!
    var _status: Int = 0
    var status:Int{
        set{
            _status = newValue
            if _status == 0 {
                cancelBut.isHidden = false
                confimBut.isHidden = false
                handleLasb.isHidden = true
                handleLasb.text = Localizeable(key: "已处理") as String
            }
            else{
                cancelBut.isHidden = true
                confimBut.isHidden = true
                handleLasb.isHidden = false
                if _status == 1 {
                    handleLasb.text = Localizeable(key: "已同意") as String
                }
                else {
                   handleLasb.text = Localizeable(key: "已拒绝") as String
                }
            }
        }
        get{
            return _status
        }
    }
    var _messStype: Int = 1
    var messStype: Int{
        set{
            _messStype = newValue
            if _messStype == 1 {
                cancelBut.isHidden = true
                confimBut.isHidden = true
                handleLasb.isHidden = true
            }
            else{
                cancelBut.isHidden = false
                confimBut.isHidden = false
                handleLasb.isHidden = false
            }
        }
        get{
            return _messStype
        }
    }
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
    
    func selectClosureWithBut(closure: tapBut?){
        tapClosure = closure
    }
    
    @IBAction func selectBut(_ sender: UIButton) {
        tapClosure?(sender.tag)
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
