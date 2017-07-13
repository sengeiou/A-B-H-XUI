//
//  DeviceListTableViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/13.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class DeviceListTableViewController: UITableViewController {
    var deviceInfo: Array<Dictionary<String, Any>>! = []
    var userInfo: UserInfo!
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMethod()
        self.title = Localizeable(key: "设备列表") as String
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initializeMethod() {
        MBProgressHUD.showMessage("正在查询...")
        let timeZone = NSTimeZone.system
        let interval = timeZone.secondsFromGMT()
        let httpMar = MyHttpSessionMar.shared
        userInfo = UnarchiveUser()
        let requestDic = RequestKeyDic()
        requestDic.addEntries(from: ["UserId": StrongGoString(object: (userInfo.userId)!),
                                     "GroupId": "",
                                     "MapType": "",
                                     "LastTime": Date().description,
                                     "TimeOffset": NSNumber(integerLiteral: interval/3600),
                                     "Token": StrongGoString(object: Defaultinfos.getValueForKey(key: AccountToken))])
        httpMar.post(Prefix + "api/Device/PersonDeviceList", parameters: requestDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            MBProgressHUD.hide()
            let resultDic = result as! Dictionary<String, Any>
            self.deviceInfo = resultDic["Items"] as! Array<Dictionary<String, Any>>
            
            DispatchQueue.main.async() { () -> Void in
                self.tableView.reloadData()
            }
        }) { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(Error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.deviceInfo.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DEVICECELL") as? DeviceTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("DeviceTableViewCell", owner: self, options: nil)?.last as? DeviceTableViewCell
        }
        let itemDic = deviceInfo[indexPath.section];
        cell?.nickLab.text = StrongGoString(object: itemDic["NickName"]) + "的表"
        cell?.phoneLab.text = "号码: " + StrongGoString(object: itemDic["Sim"])
        cell?.imeiLab.text = "IMEI: " + StrongGoString(object: itemDic["SerialNumber"])
        cell?.tapButClosure(closure: { (Button) in
            MBProgressHUD.showMessage("解绑中...")
            let requestDic = RequestKeyDic()
            requestDic.addEntries(from: ["UserId": self.userInfo.userId!,
                                         "DeviceId": StrongGoString(object: itemDic["Id"]),
                                         "UserGroupId": StrongGoString(object: itemDic["UserGroupId"])])
            let httpMgr = MyHttpSessionMar.shared
            httpMgr.post(Prefix + "api/AuthShare/RemoveShare", parameters: requestDic, progress: { (Progress) in
                
            }, success: { (URLSessionDataTask, result) in
                MBProgressHUD.hide()
                let resDic = result as! Dictionary<String,Any?>
                if resDic["State"] as! Int == 0{
                    MBProgressHUD.showSuccess(Localizeable(key: "解绑成功") as String)
                    FMDbase.shared().deleteDeviceMess(userid: self.userInfo.userId!, deviceId: StrongGoString(object: itemDic["Id"]), messType: 999)
                    FMDbase.shared().delegateDevice(userId: self.userInfo.userId!, deviceId: StrongGoString(object: itemDic["Id"]))
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }
                else{
                    MBProgressHUD.showError(resDic["Message"] as! String)
                }
                
            }, failure: { (URLSessionDataTask, Error) in
                MBProgressHUD.hide()
                MBProgressHUD.showError(Error.localizedDescription)
            })
        })
        return cell!
    }
    
}
