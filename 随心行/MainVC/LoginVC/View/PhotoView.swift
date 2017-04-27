//
//  PhotoView.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/25.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit


class PhotoView: UIView {
//    typealias passValueClosure = (UIButton) -> Void
//    var passValue:passValueClosure?
    //声明闭包
    typealias clickBtnClosure = (UIButton?) -> Void
    //把申明的闭包设置成属性
    var clickClosure: clickBtnClosure?
    //为闭包设置调用函数
    func clickValueClosure(closure:clickBtnClosure?){
        clickClosure = closure
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
         createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createUI()
    }
    
    func createUI() {
        frame = MainScreen
        backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGest(tap:)))
        addGestureRecognizer(tap)
        
        let viewHi = MainScreen.height/3 - 30
        let backView = UIView(frame: CGRect(x: 35, y: 0, width: MainScreen.width - 70, height: viewHi))
        backView.center = CGPoint(x: MainScreen.width/2, y: MainScreen.height/2 - 30)
        backView.layer.masksToBounds = true
        backView.layer.cornerRadius = 10.0
        backView.backgroundColor = UIColor.white
        addSubview(backView)
        
        let backIma = UIImageView(frame: CGRect(x: 0, y: 0, width: backView.frame.width, height: backView.frame.height))
        backIma.backgroundColor = UIColor.white
        backView.addSubview(backIma)
        let imaArr = [UIImage(named: "pic-img_moren"),UIImage(named: "pic-img_paizhao"),UIImage(named: "pic-img_xiangce")]
        let titArr = ["选择默认头像","拍照","从相册选择"]
        let imaInsets = [UIEdgeInsetsMake(0, -10, 0, 0),UIEdgeInsetsMake(0, -80, 0, 0),UIEdgeInsetsMake(0, -28, 0, 0),]
        for i in 0...2 {
            
            let but = UIButton(type: .custom)
            but.frame = CGRect(x: 40, y: 10 + 10 * CGFloat(i) + CGFloat(i) * (backView.frame.height - 40)/3, width: backView.frame.width - 80, height: (backView.frame.height - 40)/3)
            but.tag = 101 + i
            but.addTarget(self, action: #selector(butSelect(but:)), for: .touchUpInside)
            but.layer.masksToBounds = true
            but.setTitleColor(ColorFromRGB(rgbValue: 0x389aff), for: .normal)
            but.layer.cornerRadius = 6.0
            but.layer.borderColor = ColorFromRGB(rgbValue: 0x389aff).cgColor
            but.layer.borderWidth = 1.0
            but.setImage(imaArr[i], for: .normal)
            but.setTitle(titArr[i], for: .normal)
            but.imageEdgeInsets = imaInsets[i]
            backView.addSubview(but)
        }
    }
    
    func tapGest(tap: UITapGestureRecognizer) {
        removeFromSuperview()
    }
    
    func butSelect(but: UIButton) {
        clickClosure?(but)
        removeFromSuperview()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
