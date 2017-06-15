//
//  ChanPasTableViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/14.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class ChanPasTableViewController: UITableViewController {
        
    var passArr: Array<String>!
    var placeholders: Array<String>!
    var user: UserInfo!
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMethod()
        createUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createUI(){
        let backbut = UIButton(type: UIButtonType(rawValue: 0)!)
        backbut.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backbut.setTitle(Localizeable(key: "确定") as String, for: .normal)
        backbut.addTarget(self, action: #selector(tapConfim), for: UIControlEvents.touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backbut)
        
        self.title = Localizeable(key: "修改密码") as String
        tableView.tableFooterView = UIView()
        
    }
    
    func initializeMethod(){
        user = UnarchiveUser()
        passArr = [Localizeable(key: "旧密码") as String,Localizeable(key: "新密码") as String,Localizeable(key: "确认密码") as String]
        placeholders = [Localizeable(key: "输入旧密码") as String,Localizeable(key: "请设置新密码") as String,Localizeable(key: "再次输入新密码") as String]
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch")
    }
    
    func tapConfim(){
        let oldCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PassTableViewCell
        let newCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! PassTableViewCell
        let newAgainCell = tableView.cellForRow(at: IndexPath(row:2, section: 0)) as! PassTableViewCell
        
        if oldCell.passFiled.text == "" {
            MBProgressHUD.showError("请输入旧密码")
            return
        }
        
        if newCell.passFiled.text == "" || newAgainCell.passFiled.text == "" {
            MBProgressHUD.showError("请输入密码")
            return
        }
        
        if newAgainCell.passFiled.text != newCell.passFiled.text {
            MBProgressHUD.showError("两次密码不一致")
            return
        }
        let result : Bool = CheckText(str: newCell.passFiled.text!)
        if !result {
            MBProgressHUD.showError(Localizeable(key: "请输入6-16位字母数字的密码组合") as String!)
            return
        }
        
        MBProgressHUD.showMessage(Localizeable(key: "修改中...") as String)
        let requestDic = RequestKeyDic()
        requestDic.addEntries(from: ["LoginType": 0,
                                     "Id": user.userId!,
                                     "OldPass": oldCell.passFiled.text!,
                                     "NewPass": newCell.passFiled.text!,
                                     "SMSCode": ""])
        MyHttpSessionMar.shared.post(Prefix + "api/User/ChangePassword", parameters: requestDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            let resDic = result as! Dictionary<String,Any?>
            MBProgressHUD.hide()
            if resDic["State"] as! Int == 0{
                self.user.userPass = newCell.passFiled.text
                ArchiveRoot(userInfo: self.user)
                MBProgressHUD.showSuccess(Localizeable(key: "修改成功") as String)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
            else{
                MBProgressHUD.showError(resDic["Message"] as! String)
            }
        }) { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(Error.localizedDescription)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return Localizeable(key: "请输入") as String
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let lab = UILabel(frame: CGRect.init(x: 0, y: 0, width: MainScreen.size.width, height: 40))
        lab.text = Localizeable(key: "  请输入6-16位字母数字的密码组合") as String
        lab.textColor = ColorFromRGB(rgbValue: 0x1094FC)
        lab.font = UIFont.systemFont(ofSize: 12)
        return lab
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PASSCELL") as? PassTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("PassTableViewCell", owner: self, options: nil)?.last as? PassTableViewCell
        }
        cell?.titLab.text = passArr[indexPath.row]
        cell?.passFiled.placeholder = placeholders[indexPath.row]
        return cell!
    }
    
}
