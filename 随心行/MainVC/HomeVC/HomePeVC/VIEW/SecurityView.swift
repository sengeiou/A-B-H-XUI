//
//  SecurityView.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/25.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class SecurityView: UIView,UIPickerViewDelegate,UIPickerViewDataSource {
    
    typealias selectPick = (Int?) -> Void
    typealias selectBut = (Int?) -> Void
    
    var selectClosure: selectPick?
    var butClosure: selectBut?
    var pickBackView: UIView!
    var pickView: UIPickerView!
    var pickTits: Array<String>!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        if pickBackView == nil {
            createUI()
        }
    }
    
    override func layoutSubviews() {
      
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectClosureWithPick(colsure: selectPick?) {
        selectClosure = colsure
    }
    
    func selectClosureWithBut(colsure: selectBut?) {
        butClosure = colsure
    }
    
    func createUI() {
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapGest(tap:)))
        addGestureRecognizer(tapGes)
        self.backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
        pickBackView = UIView(frame: CGRect(x: 0, y: frame.height, width: frame.width, height: frame.height/2.35))
        pickBackView.backgroundColor = UIColor.white
        addSubview(pickBackView)
        
        let cancelBut = UIButton(type: .custom)
        cancelBut.frame = CGRect(x: 10, y: 0, width: 70, height: 50)
        cancelBut.setTitle(Localizeable(key: "取消") as String, for: .normal)
        cancelBut.setTitleColor(ColorFromRGB(rgbValue: 0x389AFF), for: .normal)
        cancelBut.addTarget(self, action: #selector(tapBut(sender:)), for: .touchUpInside)
        cancelBut.tag = 1001
        pickBackView.addSubview(cancelBut)
        
        let confimBut = UIButton(type: .custom)
        confimBut.frame = CGRect(x: frame.width - 80, y: 0, width: 70, height: 50)
        confimBut.setTitle(Localizeable(key: "确认") as String, for: .normal)
        confimBut.setTitleColor(ColorFromRGB(rgbValue: 0x389AFF), for: .normal)
        confimBut.addTarget(self, action: #selector(tapBut(sender:)), for: .touchUpInside)
        confimBut.tag = 1002
        pickBackView.addSubview(confimBut)
        
        let securitLab = UILabel(frame: CGRect(x: 10, y: 0, width: 120, height: 50))
        securitLab.center = CGPoint(x: frame.width/2, y: securitLab.center.y)
        securitLab.text = "区域范围"
        securitLab.textAlignment = .center
        pickBackView.addSubview(securitLab)
        
        let lineLab = UILabel(frame: CGRect(x: 0, y: securitLab.frame.maxY + 1, width: frame.width, height: 1))
        lineLab.backgroundColor = UIColor.darkGray
        pickBackView.addSubview(lineLab)
        
        pickView = UIPickerView(frame: CGRect(x: 0, y: lineLab.frame.maxY, width: frame.width, height: pickBackView.frame.height - 60))
        pickView.delegate = self
        pickView.dataSource = self
        pickBackView.addSubview(pickView)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.pickBackView.transform = CGAffineTransform(translationX: 0, y: -self.pickBackView.frame.height)
        }
            , completion: { (Bool) in
        })
    }
    
    func tapBut(sender: UIButton) {
        butClosure?(sender.tag)
        tapGest(tap: nil)
    }
    
    func tapGest(tap: UITapGestureRecognizer?) {
        UIView.animate(withDuration: 0.3, animations: {
            self.pickBackView.transform = CGAffineTransform.identity
        } , completion: { (Bool) in
            self.removeFromSuperview()
        })
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectClosure?(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickTits[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickTits.count
    }
}
