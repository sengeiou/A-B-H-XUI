//
//  NightSetViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/5.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

public protocol nightDelegate: NSObjectProtocol{
    func nightDidDisappear(dic: NSDictionary)
}

class NightSetViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var nowDateLab: UILabel!
    @IBOutlet weak var nextDateLab: UILabel!
    @IBOutlet weak var timePickView: UIPickerView!
    
    var gpsDic: NSDictionary!
    var startSelect: Int!
    var endSelect: Int!
    var deviceMode: Int!
    var delegate:nightDelegate?
    var timeArrs: Array<Array<String>>! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMethod()
        createUI()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.nightDidDisappear(dic: self.gpsDic)
    }
    
    func initializeMethod() {
        timeArrs = [[Localizeable(key: "18:00") as String,Localizeable(key: "19:00") as String,Localizeable(key: "20:00") as String,Localizeable(key: "21:00") as String,Localizeable(key: "22:00") as String],[Localizeable(key: "05:00") as String,Localizeable(key: "06:00") as String,Localizeable(key: "07:00") as String,Localizeable(key: "08:00") as String,Localizeable(key: "09:00") as String]]
        
        print("gpsDic \(gpsDic)")
        if let comValue = gpsDic["CmdValue"] as? String {
            let times = comValue.components(separatedBy: ",")
            if times.count > 1 {
                startSelect = Int((times.first?.components(separatedBy: ":").first)!)! - 18
                endSelect = Int((times.last?.components(separatedBy: ":").first)!)! - 5
            }
            else {
                startSelect = 2
                endSelect = 2
            }
        }
        else{
            startSelect = 2
            endSelect = 2
        }
        
    }
    
    func createUI() {
        title = Localizeable(key: "晚间时段") as String
        timePickView.dataSource = self
        timePickView.delegate = self
        timePickView.selectRow(startSelect, inComponent: 0, animated: false)
        timePickView.selectRow(endSelect, inComponent: 1, animated: false)
        
        let backbut = UIButton(type: UIButtonType(rawValue: 0)!)
        backbut.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        backbut.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        backbut.setTitle(Localizeable(key: "完成") as String, for: .normal)
        backbut.addTarget(self, action: #selector(complete), for: UIControlEvents.touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backbut)
    }
    
    func complete() {
        MBProgressHUD.showMessage(Localizeable(key: "正在设置...") as String)
        let user = UnarchiveUser()
        let resDic = RequestKeyDic()
        let http = MyHttpSessionMar.shared
        resDic.addEntries(from: ["DeviceId": user!.deviceId!,
                                 "DeviceModel": self.deviceMode,
                                 "CmdCode": DORMANT_TIME_BUCKET,
                                 "Params": String.init(format: "%@,%@", timeArrs[0][startSelect],timeArrs[1][endSelect]),
                                 "UserId": user!.userId!])
        print(resDic)
        http.post(Prefix + "api/Command/SendCommand", parameters: resDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            MBProgressHUD.hide()
            let resultDic = result as! Dictionary<String, Any>
            print(resultDic)
            if resultDic["State"] as! Int == 0{
                MBProgressHUD.showSuccess(Localizeable(key: "设置成功！！！") as String)
                let chDic = NSMutableDictionary(dictionary: self.gpsDic)
                chDic.addEntries(from: ["CmdValue":String.init(format: "%@,%@", self.timeArrs[0][self.startSelect],self.timeArrs[1][self.endSelect])])
                self.gpsDic = chDic
            }
            else{
                MBProgressHUD.showError(resultDic["Message"] as! String)
                
            }
        }, failure: { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(Error.localizedDescription)
        })
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeArrs[component].count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeArrs[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 67
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("com  \(component)  row \(row)")
        if component == 0 {
            startSelect = row
        }
        else{
            endSelect = row
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
