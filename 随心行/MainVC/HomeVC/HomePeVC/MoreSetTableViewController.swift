//
//  MoreSetTableViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/3.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class MoreSetTableViewController: UITableViewController {
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        cell?.selectionStyle = .none
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
                switchBut.isOn = true
                cell?.accessoryView = switchBut
            }
            if indexPath.row == 1 {
                let switchBut = UISwitch()
                switchBut.isOn = false
                cell?.accessoryView = switchBut
            }
        }
        else{
            cell?.accessoryType = .disclosureIndicator
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.setDic.count <= 0 {
            MBProgressHUD.showError(Localizeable(key: "设备数据未加载") as String)
            return
        }
        if indexPath.row == 0 && indexPath.section == 1 {
            let gpsVC = GPSViewController(nibName: "GPSViewController", bundle: nil)
            gpsVC.gpsDic = self.setDic.object(forKey: WORK_MODE) as! NSDictionary
            gpsVC.deviceMode = deviceMode
            navigationController?.pushViewController(gpsVC, animated: true)
        }
        if indexPath.row == 1 && indexPath.section == 1 {
            let gpsVC = NightSetViewController(nibName: "NightSetViewController", bundle: nil)
            gpsVC.gpsDic = self.setDic.object(forKey: DORMANT_TIME_BUCKET) as! NSDictionary
            gpsVC.deviceMode = deviceMode
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
                let user = UnarchiveUser()
                let resDic = RequestKeyDic()
                let http = MyHttpSessionMar.shared
                resDic.addEntries(from: ["DeviceId": user!.deviceId!,
                                         "DeviceModel": self.deviceMode,
                                         "CmdCode": SOUND_SIZE,
                                         "Params": String.init(format: "%d", Int! + 1),
                                         "UserId": user!.userId!])
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
                    MBProgressHUD.showError(Error.localizedDescription)
                })
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
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
