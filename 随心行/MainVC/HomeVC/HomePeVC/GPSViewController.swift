//
//  GPSViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/3.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class GPSViewController: UIViewController {
    
    @IBOutlet var normalBut: UIButton!
    @IBOutlet var saveBut: UIButton!
    @IBOutlet var trackingBut: UIButton!
    var gpsDic: NSDictionary!
    var modeSelect: Int!
    var deviceMode: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createUI() {
        title = Localizeable(key: "GPS工作模式") as String
        normalBut.layoutButtonWithEdgeInsetsStyle(style: .buttonddgeinsetsstyletopbottom, space: 20)
        saveBut.layoutButtonWithEdgeInsetsStyle(style: .buttonddgeinsetsstyletopbottom, space: 20)
        trackingBut.layoutButtonWithEdgeInsetsStyle(style: .buttonddgeinsetsstyletopbottom, space: 20)
        
        if let comValue = gpsDic["CmdValue"] as? String {
            modeSelect = Int(comValue)
            if comValue == "1" {
                normalBut.isSelected = true
            }
           else if comValue == "2" {
                saveBut.isSelected = true
            }
           else if comValue == "3" {
                trackingBut.isSelected = true
            }
           else {
                normalBut.isSelected = true
                modeSelect = 0
            }
        }
        else{
            normalBut.isSelected = true
            modeSelect = 0
        }
    }
    
    @IBAction func gpsTypeSelect(_ sender: UIButton) {

        if (sender.isSelected == true) {
            return;
        }
        normalBut.isSelected = false
        saveBut.isSelected = false
        trackingBut.isSelected = false
        sender.isSelected = true
        MBProgressHUD.showMessage(Localizeable(key: "正在设置...") as String)
        let user = UnarchiveUser()
        let resDic = RequestKeyDic()
        let http = MyHttpSessionMar.shared
        resDic.addEntries(from: ["DeviceId": user!.deviceId!,
                                 "DeviceModel": self.deviceMode,
                                 "CmdCode": WORK_MODE,
                                 "Params": String.init(format: "%d", sender.tag - 100),
                                 "UserId": user!.userId!])
        print(resDic)
        http.post(Prefix + "api/Command/SendCommand", parameters: resDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            MBProgressHUD.hide()
            let resultDic = result as! Dictionary<String, Any>
            print(resultDic)
            if resultDic["State"] as! Int == 0{
                self.modeSelect = sender.tag - 100
                MBProgressHUD.showSuccess(Localizeable(key: "设置成功！！！") as String)
            }
            else{
                MBProgressHUD.showError(resultDic["Message"] as! String)
                let oldSender = self.view.viewWithTag(101 + self.modeSelect) as! UIButton
                self.normalBut.isSelected = false
                self.saveBut.isSelected = false
                self.trackingBut.isSelected = false
                oldSender.isSelected = true
            }
        }, failure: { (URLSessionDataTask, Error) in
            MBProgressHUD.showError(Error.localizedDescription)
            let oldSender = self.view.viewWithTag(100 + self.modeSelect) as! UIButton
            self.normalBut.isSelected = false
            self.saveBut.isSelected = false
            self.trackingBut.isSelected = false
            oldSender.isSelected = true
        })
    }
}
