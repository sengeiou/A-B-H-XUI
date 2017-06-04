//
//  AddressBookTableViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/14.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class AddressBookTableViewController: UITableViewController,familyDelegate {
    var userInfo: UserInfo!
    var deviceInfo: NSMutableArray!
    var headCell: Int = 1
    var IsAdmin: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localizeable(key: "手表通讯录") as String
        initializeMethod()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeMethod() {
        MBProgressHUD.showMessage("正在查询...")
        userInfo = UnarchiveUser()
        deviceInfo = NSMutableArray()
        let requestDic = RequestKeyDic()
        requestDic.addEntries(from: ["DeviceId":StrongGoString(object: userInfo.deviceId)])
        let requestMar = MyHttpSessionMar.shared
        requestMar.post(Prefix + "api/AuthShare/ShareList", parameters: requestDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, request) in
            let resultDic = request as! Dictionary<String, Any>
            let items:Array<NSDictionary> = resultDic["Items"] as! Array<NSDictionary>
            self.deviceInfo = NSMutableArray(array: items)
            //            self.deviceInfo = items as! NSMutableArray
            DispatchQueue.main.async() { () -> Void in
                MBProgressHUD.hide()
                self.tableView.reloadData()
            }
            for i in 0...(items.count - 1){
                let itemDic = items[i]
                if (self.userInfo.userId == StrongGoString(object: itemDic["UserId"]) && Int((itemDic["IsAdmin"] as? NSNumber)!) == 1){
                    self.headCell = 2
                }
            }
            
            print("resultDic \(self.deviceInfo)")
        }) { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(Error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return headCell
        }
        return deviceInfo.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            return 50
        }
        return 75
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ADDRESSBOOKCELL")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ADDRESSBOOKCELL")
            cell?.layer.shouldRasterize = true;
            cell?.layer.rasterizationScale = UIScreen.main.scale;
        }
        cell?.selectionStyle = .none
        if indexPath.section == 0 && indexPath.row == 0 {
            let imaData = NSData(base64Encoded: self.userInfo.deviceIma!, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
            let iamge: UIImage? = UIImage(data: imaData! as Data)
            if iamge == nil {
                cell?.imageView?.image = drawImaSize(image: #imageLiteral(resourceName: "icon_img_3"), size: CGSize(width: 80, height: 80))
            }
            else{
                cell?.imageView?.image = drawImaSize(image: iamge!, size: CGSize(width: 80, height: 80))
            }
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 20)
            cell?.textLabel?.text = self.userInfo.deviceName
            cell?.detailTextLabel?.text = self.userInfo.devicePh
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            cell?.detailTextLabel?.textColor = UIColor.gray
            cell?.accessoryType = .none
        }
        else if indexPath.section == 0 && indexPath.row == 1 {
            cell?.imageView?.image = drawImaSize(image: #imageLiteral(resourceName: "ic_add-family"), size: CGSize(width: 30, height: 30))
            cell?.textLabel?.text = "添加家人"
            cell?.accessoryType = .disclosureIndicator
        }
        else {
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 17)
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.detailTextLabel?.textColor = UIColor.gray
            let itemDic = deviceInfo[indexPath.row] as! NSDictionary
            let imaData = NSData(base64Encoded: StrongGoString(object: itemDic.object(forKey: "Avatar")), options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
            let iamge: UIImage? = UIImage(data: imaData! as Data)
            if iamge == nil {
                cell?.imageView?.image = drawImaSize(image: #imageLiteral(resourceName: "icon_img_3"), size: CGSize(width: 50, height: 50))
            }
            else{
                cell?.imageView?.image = drawImaSize(image: iamge!, size: CGSize(width: 50, height: 50))
            }
            cell?.detailTextLabel?.text = StrongGoString(object: itemDic.object(forKey: "RelationPhone"))
            print(itemDic["IsAdmin"]!)
            if Int((itemDic["IsAdmin"] as? NSNumber)!) == 1{
                cell?.accessoryType = .disclosureIndicator
                if userInfo.userPh == StrongGoString(object: itemDic.object(forKey: "RelationPhone")) {
                    IsAdmin = true
                    cell?.textLabel?.attributedText = attributedString(strArr: [String.init(format: "我(%@)", StrongGoString(object: itemDic.object(forKey: "RelationName"))),Localizeable(key: " (管理员)") as String], fontArr: [UIFont .systemFont(ofSize: 20),UIFont .systemFont(ofSize: 16)], colorArr: [UIColor.black,ColorFromRGB(rgbValue: 0x59AAFD)])
                }
                else{
                    cell?.textLabel?.attributedText = attributedString(strArr: [String.init(format: "%@", StrongGoString(object: itemDic.object(forKey: "RelationName"))),Localizeable(key: " (管理员)") as String], fontArr: [UIFont .systemFont(ofSize: 20),UIFont .systemFont(ofSize: 16)], colorArr: [UIColor.black,ColorFromRGB(rgbValue: 0x59AAFD)])
                }
            }
            else{
                cell?.accessoryType = .disclosureIndicator
                if userInfo.userPh == StrongGoString(object: itemDic.object(forKey: "RelationPhone")) {
                    cell?.textLabel?.attributedText = attributedString(strArr: [String.init(format: "我(%@)", StrongGoString(object: itemDic.object(forKey: "RelationName")))], fontArr: [UIFont .systemFont(ofSize: 20)], colorArr: [UIColor.black])
                }
                else{
                    cell?.textLabel?.attributedText = attributedString(strArr: [StrongGoString(object: itemDic.object(forKey: "RelationName"))], fontArr: [UIFont .systemFont(ofSize: 20)], colorArr: [UIColor.black])
                }
            }
        }
        cell?.imageView?.layer.masksToBounds = true
        cell?.imageView?.layer.cornerRadius = (cell?.imageView?.frame.height)!/2
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            navigationController?.pushViewController(AddFamilyViewController(), animated: true)
        }
        else if indexPath.section != 0{
            let familyVC = FamilyViewController(nibName: "FamilyViewController", bundle: nil)
            familyVC.relationDic = deviceInfo[indexPath.row] as! NSDictionary
            familyVC.delegate = self
            familyVC.IsAdmin = IsAdmin
            navigationController?.pushViewController(familyVC, animated: true)
        }
    }
    
    func permissionManagers() {
        initializeMethod()
    }
    
    func  delegateRelation(relationDic: NSDictionary){
        deviceInfo.remove(relationDic)
        tableView.reloadData()
    }
}

