//
//  VolumeView.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/5.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class VolumeView: UIView,UIPickerViewDelegate,UIPickerViewDataSource {

    typealias selectPick = (Int?,String) -> Void
    var volumes: Array<String> = [Localizeable(key: "高") as String,Localizeable(key: "中") as String,Localizeable(key: "低") as String]
    var selectClosure: selectPick?
    var VolumepickView: UIPickerView!
    var selectIndex: Int! = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectClosureWithPick(colsure: selectPick?) {
        selectClosure = colsure
    }
    
    func createUI() {
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapGest(tap:)))
        addGestureRecognizer(tapGes)
        
        backgroundColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.4)
        VolumepickView = UIPickerView(frame: CGRect(x: 0, y:self.frame.size.height - 200, width: frame.size.width, height: 200))
        VolumepickView.delegate = self
        VolumepickView.backgroundColor = UIColor.white
        VolumepickView.dataSource = self
        VolumepickView.selectRow(2, inComponent: 0, animated: false)
        selectIndex = 2
        addSubview(VolumepickView)
        
        let canBut = UIButton(type: .custom)
        canBut.frame = CGRect(x: 0, y: VolumepickView.frame.minY - 50, width: MainScreen.width/2, height: 50)
        canBut.backgroundColor = UIColor.darkGray
        canBut.setTitle(Localizeable(key: "取消")as String, for: .normal)
        canBut.tag = 1001;
        canBut.addTarget(self, action: #selector(touchBut(sender:)), for: .touchUpInside)
        addSubview(canBut)
        
        let confim = UIButton(type: .custom)
        confim.frame = CGRect(x: canBut.frame.maxX, y: VolumepickView.frame.minY - 50, width: MainScreen.width/2, height: 50)
        confim.backgroundColor = ColorFromRGB(rgbValue: 0x389aff)
        confim.setTitle(Localizeable(key: "确认")as String, for: .normal)
        confim.tag = 1002;
        confim.addTarget(self, action: #selector(touchBut(sender:)), for: .touchUpInside)
        addSubview(confim)
    }
    
    func tapGest(tap: UITapGestureRecognizer?) {
            self.removeFromSuperview()
    }

    
    func touchBut(sender: UIButton?) {
        if sender?.tag != 1001 {
             selectClosure?(selectIndex,volumes[selectIndex])
        }
         removeFromSuperview()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return volumes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return volumes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 67
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectIndex = row
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
