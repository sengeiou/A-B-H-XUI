//
//  MeTableViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/2.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class MeTableViewController: UITableViewController {
    var titArr: Array<Array<String>> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMethod()
        title = Localizeable(key: "我的") as String
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeMethod(){
        titArr = [[Localizeable(key: "账号信息") as String],[Localizeable(key: "设备列表") as String,Localizeable(key: "密码修改") as String],[Localizeable(key: "常见问题") as String,Localizeable(key: "关于") as String],[Localizeable(key: "退出登录") as String]]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return titArr.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titArr[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section != 3 {
            let cellIndent = "MECELL"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIndent)
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: cellIndent)
            }
            cell?.textLabel?.text = titArr[indexPath.section][indexPath.row]
            cell?.selectionStyle = .none
            cell?.accessoryType = .disclosureIndicator
            return cell!
        }
        else{
            let cellIndent = "SIGNOUTELL"
            var cell = tableView.dequeueReusableCell(withIdentifier: cellIndent)
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: cellIndent)
            }
            cell?.selectionStyle = .none
            let signoutLab = UILabel(frame: (cell?.contentView.bounds)!)
            signoutLab.textColor = ColorFromRGB(rgbValue: 0x59AAFD)
            signoutLab.textAlignment = .center
            signoutLab.text = titArr[indexPath.section][indexPath.row]
            cell?.contentView.addSubview(signoutLab)
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 90
        }
        return 20
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let deviceVC = DeviceInfoViewController(nibName: "DeviceInfoViewController", bundle: nil)
            deviceVC.changeUser = true
            deviceVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(deviceVC, animated: true)
        }
        if (indexPath.section == 1 && indexPath.row == 0) {
            let deviceLiVC = DeviceListTableViewController(nibName: "DeviceListTableViewController", bundle: nil)
            deviceLiVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(deviceLiVC, animated: true)
        }
        
        if (indexPath.section == 1 && indexPath.row == 1) {
            let changeVC = ChanPasTableViewController(nibName: "ChanPasTableViewController", bundle: nil)
            changeVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(changeVC, animated: true)
        }
        
        if (indexPath.section == 2 && indexPath.row == 0) {
            let changeVC = HelpViewController(nibName: "HelpViewController", bundle: nil)
            changeVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(changeVC, animated: true)
        }
        
        if (indexPath.section == 2 && indexPath.row == 1) {
            let changeVC = AboutUsViewController(nibName: "AboutUsViewController", bundle: nil)
            changeVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(changeVC, animated: true)
        }
        if indexPath.section == 3 {
            let aler = UIAlertController(title: Localizeable(key: "是否退出登录？") as String, message: nil, preferredStyle: .alert)
            let canAct = UIAlertAction(title: "取消", style: .cancel, handler: { (AlertAction) in
                
            })
            let conAct = UIAlertAction(title: "确定", style: .default, handler: { (AlertAction) in
            ArchiveRoot(userInfo: getNewUser())
                Defaultinfos.removeValueForKey(key: Account)
                Defaultinfos.removeValueForKey(key: AccountToken)
                let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
                let nav = NavViewController(rootViewController: loginVC)
                UIApplication.shared.keyWindow?.rootViewController = nav

            })
            aler.addAction(canAct)
            aler.addAction(conAct)
            present(aler, animated: true, completion: { 
                
            })
        }
    }
    
}
