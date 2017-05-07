//
//  DeviceToolView.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/6.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class DeviceToolView: UIView {
    
    typealias tapBut = (Int) -> Void
    var tapClosure: tapBut?
    
    func tapClosureWithBut(colsure: tapBut?) {
        tapClosure = colsure
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createUI() {
        backgroundColor = ColorFromRGB(rgbValue: 0xECECEC)
        let imaArr: Array<UIImage> = [#imageLiteral(resourceName: "icon_call"),#imageLiteral(resourceName: "icon_foot"),#imageLiteral(resourceName: "icon_bill"),#imageLiteral(resourceName: "icon_phonebook"),#imageLiteral(resourceName: "icon_pu"),#imageLiteral(resourceName: "icon_morning")]
        let titArr: Array<NSString> = [Localizeable(key: "打电话"),Localizeable(key: "看足迹"),Localizeable(key: "查话费"),Localizeable(key: "通讯录"),Localizeable(key: "安全圈"),Localizeable(key: "问声好")]
        for i in 0...5 {
            let butView = UIButton(type: .custom)
            butView.frame = CGRect(x: CGFloat(i%3) * MainScreen.width/3, y: CGFloat(i/3) * frame.height/2, width: MainScreen.width/3, height: frame.height/2)
            addSubview(butView)
            butView.setImage(imaArr[i], for: .normal)
            butView.setTitle(titArr[i] as String, for: .normal)
            butView.setTitleColor(UIColor.black, for: .normal)
            butView.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            butView.tag = 101 + i
            butView.layoutButtonWithEdgeInsetsStyle(style: .buttonddgeinsetsstyletop, space: 16)
            butView.addTarget(self, action: #selector(tapViewBut(sender:)), for: .touchUpInside)
            print(butView.frame)
        }
    }
    
    func tapViewBut(sender: UIButton) {
        tapClosure?(sender.tag)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
