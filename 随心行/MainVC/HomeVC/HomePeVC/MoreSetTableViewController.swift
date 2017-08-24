//
//  MoreSetTableViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/3.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class MoreSetTableViewController: UITableViewController,gpsDelegate,nightDelegate {
    
    var titArr: Array<Array<String>>!
    var setDic: NSMutableDictionary!
    var deviceMode: Int!
    lazy var userInfo: UserInfo = {
        let userInfo = UnarchiveUser()
        return userInfo!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMethod()
        createUI()
        NotificaCenter.addObserver(self, selector: #selector(notifiction), name: Notification.Name(rawValue: "updateSetting"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestCommand()
    }
    
    deinit {
        NotificaCenter.removeObserver(self, name: Notification.Name(rawValue: "updateSetting"), object: nil)
    }
    
    func notifiction() {
        print("接收到通知")
        requestCommand()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initializeMethod() {
        setDic = NSMutableDictionary()
        titArr = [[Localizeable(key: "手表账号") as String],[Localizeable(key: "GPS工作模式")as String,Localizeable(key: "晚间时段")as String,Localizeable(key: "手表铃声及通话音量")as String],[Localizeable(key: "屏蔽陌生号码")as String,Localizeable(key: "随心夹子连接")as String],[Localizeable(key: "解除绑定")as String,Localizeable(key: "更换随心夹子")as String]]
    }
    
    func createUI() {
        title = Localizeable(key: "手表设置") as String
        tableView.showsVerticalScrollIndicator = false;
    }
    
    func requestCommand() {
        let requestDic = RequestKeyDic()
        requestDic.addEntries(from: ["DeviceId": userInfo.deviceId!])
        MyHttpSessionMar.shared.post(Prefix + "api/Command/CommandList", parameters: requestDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            let resultDic = result as! Dictionary<String, Any>
            let items:Array<Dictionary<String, Any>> = resultDic["Items"] as! Array<Dictionary<String, Any>>
            print(items)
            for comDic in items{
                switch comDic["Code"] as! String{
                case WORK_MODE:
                    self.setDic.addEntries(from: [WORK_MODE:comDic])
                    break
                case DORMANT_TIME_BUCKET:
                    self.setDic.addEntries(from: [DORMANT_TIME_BUCKET:comDic])
                    break
                case SOUND_SIZE:
                    self.setDic.addEntries(from: [SOUND_SIZE:comDic])
                    break
                case SHIELD_OTHER_PHONE:
                    self.setDic.addEntries(from: [SHIELD_OTHER_PHONE:comDic])
                    break
                case SHIELD_DEVICE:
                    self.setDic.addEntries(from: [SHIELD_DEVICE:comDic])
                    break
                case CHANGE_DEVICE:
                    self.setDic.addEntries(from: [CHANGE_DEVICE:comDic])
                    break
                default:
                    break
                }
            }
            print(self.setDic)
            self.tableView.reloadData()
        }) { (URLSessionDataTask, Error) in
            
        }
    }
    
    func tapSwift(sender: UISwitch) {
        
        if self.setDic.count <= 0 {
            MBProgressHUD.showError(Localizeable(key: "设备数据未加载") as String)
            return
        }
        let gpsDic = self.setDic.object(forKey: SHIELD_OTHER_PHONE) as! NSDictionary
        
        if sender.tag == 1001 {
            MBProgressHUD.showMessage(Localizeable(key: "正在设置...") as String)
            let resDic = RequestKeyDic()
            let http = MyHttpSessionMar.shared
            resDic.addEntries(from: ["DeviceId": self.userInfo.deviceId!,
                                     "DeviceModel": self.deviceMode,
                                     "CmdCode": SHIELD_OTHER_PHONE,
                                     "Params": String.init(format: "%@", (sender.isOn == true) ? "1" : "0"),
                                     "UserId": self.userInfo.userId!])
            print(resDic)
            http.post(Prefix + "api/Command/SendCommand", parameters: resDic, progress: { (Progress) in
                
            }, success: { (URLSessionDataTask, result) in
                MBProgressHUD.hide()
                let resultDic = result as! Dictionary<String, Any>
                if resultDic["State"] as! Int == 0{
                    MBProgressHUD.showSuccess(Localizeable(key: "设置成功！！！") as String)
                    let dic = NSMutableDictionary(dictionary: gpsDic)
                    dic.addEntries(from: ["CmdValue": String.init(format: "%@", (sender.isOn == true) ? "1" : "0")])
                    self.setDic.addEntries(from: [SHIELD_OTHER_PHONE: dic])
                }
                else{
                    MBProgressHUD.showError(resultDic["Message"] as! String)
                    sender.isOn = !sender.isOn
                }
            }, failure: { (URLSessionDataTask, Error) in
                MBProgressHUD.hide()
                if (Error as NSError).code == -999{
                    return;
                }
                MBProgressHUD.showError(Error.localizedDescription)
                sender.isOn = !sender.isOn
            })
            
        }
        else{
            MBProgressHUD.showMessage(Localizeable(key: "正在设置...") as String)
            let resDic = RequestKeyDic()
            let http = MyHttpSessionMar.shared
            resDic.addEntries(from: ["DeviceId": self.userInfo.deviceId!,
                                     "DeviceModel": self.deviceMode,
                                     "CmdCode": SHIELD_DEVICE,
                                     "Params": String.init(format: "%@", (sender.isOn == true) ? "1" : "0"),
                                     "UserId": self.userInfo.userId!])
            http.post(Prefix + "api/Command/SendCommand", parameters: resDic, progress: { (Progress) in
                
            }, success: { (URLSessionDataTask, result) in
                MBProgressHUD.hide()
                let resultDic = result as! Dictionary<String, Any>
                print(resultDic)
                if resultDic["State"] as! Int == 0{
                    MBProgressHUD.showSuccess(Localizeable(key: "设置成功！！！") as String)
                    let dic = NSMutableDictionary(dictionary: gpsDic)
                    dic.addEntries(from: ["CmdValue": String.init(format: "%@", (sender.isOn == true) ? "1" : "0")])
                    self.setDic.addEntries(from: [SHIELD_DEVICE: dic])
                }
                else{
                    MBProgressHUD.showError(resultDic["Message"] as! String)
                    sender.isOn = !sender.isOn
                }
            }, failure: { (URLSessionDataTask, Error) in
                MBProgressHUD.hide()
                if (Error as NSError).code == -999{
                    return;
                }
                MBProgressHUD.showError(Error.localizedDescription)
                sender.isOn = !sender.isOn
            })
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return titArr.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titArr[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DEVICESETCELL")
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "DEVICESETCELL")
        }
//        cell?.selectionStyle = .none
        cell?.textLabel?.text = titArr[indexPath.section][indexPath.row]
        cell?.detailTextLabel?.text = ""
        cell?.accessoryView = nil
        cell?.accessoryType = .none
        if indexPath.section == 0 {
            cell?.detailTextLabel?.text = userInfo.devicePh
            cell?.accessoryType = .disclosureIndicator
        }
        else if indexPath.section == 1{
            cell?.accessoryType = .disclosureIndicator
            if self.setDic.count > 0 {
                if indexPath.row == 0 {
                    let strs = [Localizeable(key: "正常模式") as String,Localizeable(key: "省电模式") as String,Localizeable(key: "跟踪模式") as String]
                    let gpsDic = self.setDic.object(forKey: WORK_MODE) as! NSDictionary
                    if let comValue = gpsDic["CmdValue"] as? String {
                        if comValue != "" {
                            cell?.detailTextLabel?.text = strs[Int(comValue)! - 1]
                        }
                        else {
                            cell?.detailTextLabel?.text = strs.first
                        }
                    }
                    else{
                        cell?.detailTextLabel?.text = strs.first
                    }
                    
                }
                if indexPath.row == 1 {
                    let gpsDic = self.setDic.object(forKey: DORMANT_TIME_BUCKET) as! NSDictionary
                    if let comValue = gpsDic["CmdValue"] as? String {
                        let times = comValue.components(separatedBy: ",")
                        if times.count > 1 {
                            cell?.detailTextLabel?.text = String.init(format: "%@ -- %@", times.first!,times.last!)
                        }
                        else {
                            cell?.detailTextLabel?.text = "20:00 -- 07:00"
                        }
                    }
                    else{
                        cell?.detailTextLabel?.text = "20:00 -- 07:00"
                    }
                }
                if indexPath.row == 2 {
                    let dic =  NSMutableDictionary(dictionary: self.setDic.object(forKey: SOUND_SIZE) as! Dictionary)
                    let strs = [Localizeable(key: "高") as String,Localizeable(key: "中") as String,Localizeable(key: "低") as String]
                    if let comValue = dic["CmdValue"] as? String {
                        if comValue != "" {
                            cell?.detailTextLabel?.text = strs[Int(comValue)! - 1]
                        }
                        else {
                            cell?.detailTextLabel?.text = strs.last
                        }
                    }
                    else{
                        cell?.detailTextLabel?.text = strs.last
                    }
                }
            }
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let switchBut = UISwitch()
                switchBut.onTintColor = ColorFromRGB(rgbValue: 0x389aff)
                switchBut.tag = 1001
                switchBut.isOn = false
                switchBut.addTarget(self, action: #selector(tapSwift(sender:)), for: .valueChanged)
                cell?.accessoryView = switchBut
                guard let gpsDic = self.setDic.object(forKey: SHIELD_OTHER_PHONE) as? NSDictionary,let value = gpsDic["CmdValue"] as? String, value == "1" else {
                    return cell!
                }
                switchBut.isOn = true
            }
            if indexPath.row == 1 {
                let switchBut = UISwitch()
                switchBut.onTintColor = ColorFromRGB(rgbValue: 0x389aff)
                switchBut.tag = 1002
                switchBut.isOn = false
                switchBut.addTarget(self, action: #selector(tapSwift(sender:)), for: .valueChanged)
                cell?.accessoryView = switchBut
                guard let gpsDic = self.setDic.object(forKey: SHIELD_DEVICE) as? NSDictionary,let value = gpsDic["CmdValue"] as? String, value == "1" else {
                    return cell!
                }
                switchBut.isOn = true
            }
        }
        else{
            cell?.accessoryType = .disclosureIndicator
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let cell0 = self.tableView.cellForRow(at: indexPath)
        cell0?.isSelected = false
        print("didSelectRowAt \(cell0?.isSelected)")
        if self.setDic.count <= 0 {
            MBProgressHUD.showError(Localizeable(key: "设备数据未加载") as String)
            return
        }
        if indexPath.row == 0 && indexPath.section == 0 {
            let deviceVC = DeviceInfoViewController(nibName: "DeviceInfoViewController", bundle: nil)
            deviceVC.changeDevice = true
            navigationController?.pushViewController(deviceVC, animated: true)
        }
        if indexPath.row == 0 && indexPath.section == 1 {
            let gpsVC = GPSViewController(nibName: "GPSViewController", bundle: nil)
            gpsVC.gpsDic = self.setDic.object(forKey: WORK_MODE) as! NSDictionary
            gpsVC.deviceMode = deviceMode
            gpsVC.delegate = self
            navigationController?.pushViewController(gpsVC, animated: true)
        }
        if indexPath.row == 1 && indexPath.section == 1 {
            let gpsVC = NightSetViewController(nibName: "NightSetViewController", bundle: nil)
            gpsVC.gpsDic = self.setDic.object(forKey: DORMANT_TIME_BUCKET) as! NSDictionary
            gpsVC.deviceMode = deviceMode
            gpsVC.delegate = self
            navigationController?.pushViewController(gpsVC, animated: true)
        }
        
        if indexPath.row == 2 && indexPath.section == 1 {
            let volumeView = VolumeView(frame: MainScreen)
            let appDelete = UIApplication.shared.delegate as! AppDelegate
            appDelete.window?.addSubview(volumeView)
            var selectIndex = 0
            let dic =  NSMutableDictionary(dictionary: self.setDic.object(forKey: SOUND_SIZE) as! Dictionary)
            if let comValue = dic["CmdValue"] as? String {
                if comValue != "" {
                    selectIndex = Int(comValue)! - 1
                    volumeView.VolumepickView.selectRow(selectIndex, inComponent: 0, animated: false)
                }
                else {
                    selectIndex = 2
                    volumeView.VolumepickView.selectRow(selectIndex, inComponent: 0, animated: false)
                }
            }
            else{
                selectIndex = 2
                volumeView.VolumepickView.selectRow(selectIndex, inComponent: 0, animated: false)
            }
            
            volumeView.selectClosureWithPick(colsure: { (Int,string) in
                MBProgressHUD.showMessage(Localizeable(key: "正在设置...") as String)
                let resDic = RequestKeyDic()
                let http = MyHttpSessionMar.shared
                resDic.addEntries(from: ["DeviceId": self.userInfo.deviceId!,
                                         "DeviceModel": self.deviceMode,
                                         "CmdCode": SOUND_SIZE,
                                         "Params": String.init(format: "%d", Int! + 1),
                                         "UserId": self.userInfo.userId!])
                print(resDic)
                http.post(Prefix + "api/Command/SendCommand", parameters: resDic, progress: { (Progress) in
                    
                }, success: { (URLSessionDataTask, result) in
                    MBProgressHUD.hide()
                    let resultDic = result as! Dictionary<String, Any>
                    print(resultDic)
                    if resultDic["State"] as! Int == 0{
                        MBProgressHUD.showSuccess(Localizeable(key: "设置成功！！！") as String)
                        dic.addEntries(from: ["CmdValue": String.init(format: "%d", Int! + 1)])
                        self.setDic.addEntries(from: [SOUND_SIZE: dic])
                        let cell = self.tableView.cellForRow(at: indexPath)
                        cell?.detailTextLabel?.text = string
                    }
                    else{
                        MBProgressHUD.showError(resultDic["Message"] as! String)
                        
                    }
                }, failure: { (URLSessionDataTask, Error) in
                    MBProgressHUD.hide()
                    if (Error as NSError).code == -999{
                        return;
                    }
                    MBProgressHUD.showError(Error.localizedDescription)
                })
            })
        }
        if indexPath.section == 3 && indexPath.row == 0 {
            let aler = UIAlertController(title: "是否解除绑定手表？", message: nil, preferredStyle: .alert)
            let cancelAct = UIAlertAction(title: "取消", style: .default, handler: { (UIAlertAction) in
                
            })
            let conAct = UIAlertAction(title: "解绑", style: .default, handler: { (UIAlertAction) in
                MBProgressHUD.showMessage(Localizeable(key: "正在解绑...") as String)
                var GroupId = ""
                let resDic = RequestKeyDic()
                let http = MyHttpSessionMar.shared
                resDic.addEntries(from: ["DeviceId":StrongGoString(object: self.userInfo.deviceId)])
                http.post(Prefix + "api/AuthShare/ShareList", parameters: resDic, progress: { (Progress) in
                    
                }, success: { (URLSessionDataTask, request) in
                    let resultDic = request as! Dictionary<String, Any>
                    let items:Array<NSDictionary> = resultDic["Items"] as! Array<NSDictionary>
                    for i in 0...(items.count - 1){
                        let itemDic = items[i]
                        print("jiojg  \(items.count)")
                        if (self.userInfo.userId == StrongGoString(object: itemDic["UserId"])){
                            GroupId =  StrongGoString(object: itemDic["UserGroupId"])
                            break
                        }
                    }
                   
                    let resDic0 = RequestKeyDic()
                    resDic0.addEntries(from: ["UserId": self.userInfo.userId!,
                                              "DeviceId": self.userInfo.deviceId!,
                                              "UserGroupId": GroupId])
                     print(resDic0)
                    http.post(Prefix + "api/AuthShare/RemoveShare", parameters: resDic0, progress: { (Progress) in
                        
                    }, success: { (URLSessionDataTask, result) in
                        MBProgressHUD.hide()
                        let resultDic = result as! Dictionary<String, Any>
                        print(resultDic)
                        if resultDic["State"] as! Int == 0{
                            MBProgressHUD.showSuccess(Localizeable(key: "解绑成功！！！") as String)
                            FMDbase.shared().deleteDeviceMess(userid: self.userInfo.userId!, deviceId: self.userInfo.deviceId!, messType: 999)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        else{
                            MBProgressHUD.showError(resultDic["Message"] as! String)
                            
                        }
                    }, failure: { (URLSessionDataTask, Error) in
                        MBProgressHUD.hide()
                        if (Error as NSError).code == -999{
                            return;
                        }
                        MBProgressHUD.showError(Error.localizedDescription)
                    })
                    
                    
                }) { (URLSessionDataTask, Error) in
                    MBProgressHUD.hide()
                    MBProgressHUD.showError(Error.localizedDescription)
                }
            })
            aler.addAction(cancelAct)
            aler.addAction(conAct)
            present(aler, animated: true, completion: {
                
            })
            
        }
        if indexPath.section == 3 && indexPath.row == 1 {
            let aler = UIAlertController(title: "是否更换随心夹子？", message: nil, preferredStyle: .alert)
            let cancelAct = UIAlertAction(title: "取消", style: .default, handler: { (UIAlertAction) in
                
            })
            let conAct = UIAlertAction(title: "确认", style: .default, handler: { (UIAlertAction) in
                MBProgressHUD.showMessage(Localizeable(key: "正在更换...") as String)
                let resDic = RequestKeyDic()
                let http = MyHttpSessionMar.shared
                resDic.addEntries(from: ["DeviceId": self.userInfo.deviceId!,
                                         "DeviceModel": self.deviceMode,
                                         "CmdCode": CHANGE_DEVICE,
                                         "Params": "1234567",
                                         "UserId": self.userInfo.userId!])
                print(resDic)
                http.post(Prefix + "api/Command/SendCommand", parameters: resDic, progress: { (Progress) in
                    
                }, success: { (URLSessionDataTask, result) in
                    MBProgressHUD.hide()
                    let resultDic = result as! Dictionary<String, Any>
                    print(resultDic)
                    if resultDic["State"] as! Int == 0{
                        MBProgressHUD.showSuccess(Localizeable(key: "更换成功！！！") as String)
                        let dic =  NSMutableDictionary(dictionary: self.setDic.object(forKey: CHANGE_DEVICE) as! Dictionary)
                        dic.addEntries(from: ["CmdValue": "1234567"])
                        self.setDic.addEntries(from: [CHANGE_DEVICE: dic])
                    }
                    else{
                        MBProgressHUD.showError(resultDic["Message"] as! String)
                        
                    }
                }, failure: { (URLSessionDataTask, Error) in
                    MBProgressHUD.hide()
                    if (Error as NSError).code == -999{
                        return;
                    }
                    MBProgressHUD.showError(Error.localizedDescription)
                })
            })
            aler.addAction(cancelAct)
            aler.addAction(conAct)
            present(aler, animated: true, completion: {
                
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func gpsDidDisappear(dic: NSDictionary) {
        self.setDic.addEntries(from: [WORK_MODE: dic])
        let strs = [Localizeable(key: "正常模式") as String,Localizeable(key: "省电模式") as String,Localizeable(key: "跟踪模式") as String]
        print(self.setDic);
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1))
        if let comValue = dic["CmdValue"] as? String {
            if comValue != "" {
                cell?.detailTextLabel?.text = strs[Int(comValue)! - 1]
            }
            else {
                cell?.detailTextLabel?.text = strs.first
            }
        }
        else{
            cell?.detailTextLabel?.text = strs.first
        }
    }
    
    func nightDidDisappear(dic: NSDictionary) {
        self.setDic.addEntries(from: [DORMANT_TIME_BUCKET: dic])
        let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 1))
        if let comValue = dic["CmdValue"] as? String {
            let times = comValue.components(separatedBy: ",")
            if times.count > 1 {
                cell?.detailTextLabel?.text = String.init(format: "%@ -- %@", times.first!,times.last!)
            }
            else {
                cell?.detailTextLabel?.text = "20:00 -- 07:00"
            }
        }
        else{
            cell?.detailTextLabel?.text = "20:00 -- 07:00"
        }
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
