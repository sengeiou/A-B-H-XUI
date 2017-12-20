//
//  MessTableViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/2.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class MessTableViewController: UITableViewController {
    var messArrs: NSMutableArray!
    var detailArrs: NSMutableArray!
    var user: UserInfo!
    //    var alertArr: NSMutableArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeMethod() {
        user = UnarchiveUser()
        messArrs = NSMutableArray()
        detailArrs = NSMutableArray()
        messArrs.add([Localizeable(key: "报警消息") as String, Localizeable(key: "申请消息") as String])
        let devices = FMDbase.shared().selectUsers(userid: user.userId!)
        guard devices != nil, (devices?.count)! > 0 else {
            //            DispatchQueue.main.async() { () -> Void in
            //                print("1111111111111111111111111111111111111")
            //                self.tableView.reloadData()
            //            }
            return
        }
        messArrs.add(devices!)
        
        let sql = FMDbase.shared()
        let alertMess = sql.selectMess(userid: user.userId!, deviceId: nil, messType: 1)
        let applyMess = sql.selectMess(userid: user.userId!, deviceId: nil, messType: 3)
        detailArrs.add(alertMess)
        detailArrs.add(applyMess)
        print(detailArrs)
        guard messArrs.count > 1,let msss = messArrs.lastObject as? NSMutableArray else {
            //            DispatchQueue.main.async() { () -> Void in
            //                print("2222222222222222222222222222222222222222222")
            //                self.tableView.reloadData()
            //            }
            return
        }
        let deviceArr = NSMutableArray()
        for device in msss {
            let devi = device as! UserInfo
            let deviceMess = sql.selectMess(userid: devi.userId!, deviceId: devi.deviceId, messType: 999)
            deviceArr.add(deviceMess)
        }
        detailArrs.add(deviceArr)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initializeMethod()
        DispatchQueue.main.async() { () -> Void in
            self.tableView.reloadData()
        }
        
    }
    
    func createUI() {
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return messArrs.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("(messArrs[section] as! NSArray).count  \((messArrs[section] as! NSArray).count)")
        return (messArrs[section] as! NSArray).count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return nil
        }
        return Localizeable(key: "回复消息") as String
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MESSAGECELL")  as? MessTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("MessTableViewCell", owner: self, options: nil)?.last as? MessTableViewCell
        }
        cell?.selectionStyle = .none
        if indexPath.section == 0{
            let imadata = NSData(base64Encoded: (user.userIma == nil) ? "":user.userIma!, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
            var iamge: UIImage? = UIImage(data: imadata! as Data)
            if iamge == nil {
                iamge = #imageLiteral(resourceName: "pic-img_moren")
            }
            cell?.headIma.image = iamge?.drawCornerIma(Sise: nil)
            if let array = messArrs[indexPath.section] as? NSArray,let text = array[indexPath.row] as? String {
                cell?.titLab.text = text
            }
            else{
                cell?.titLab.text = ""
            }
            if indexPath.row == 0 {
                if Defaultinfos.getIntValueForKey(key: warningNum) > 0 {
                    cell?.notiLab.isHidden = false
                }
            }
            else{
                if Defaultinfos.getIntValueForKey(key: applyForNum) > 0 {
                    cell?.notiLab.isHidden = false
                }
            }
            guard detailArrs.count > 0, let mesArr = detailArrs[indexPath.row] as? NSMutableArray, let dic = mesArr.lastObject as? NSDictionary, let time = dic["DATE"] as? String else{
                cell?.timeLab.text = ""
                guard detailArrs.count > 0, let mesArr = detailArrs[indexPath.row] as? NSMutableArray, let dic = mesArr.lastObject as? NSDictionary, let mess = dic["MESSAGE"] as? String else{
                    cell?.messLab.text = "暂无信息"
                    return cell!
                }
                cell?.messLab.text = mess
                return cell!
            }
            let b = NSMutableCharacterSet(charactersIn:" ")
            b.addCharacters(in: "/")
            let dateS = time.components(separatedBy: b as CharacterSet)
            cell?.timeLab.text = String.init(format: "%@", dateS[3])
            
            guard detailArrs.count > 0, let mesArr0 = detailArrs[indexPath.row] as? NSMutableArray, let dic0 = mesArr0.lastObject as? NSDictionary, let mess0 = dic0["MESSAGE"] as? String else{
                cell?.messLab.text = "暂无信息"
                return cell!
            }
            cell?.messLab.text = mess0
        }
        else{
            let deviceInfo = (messArrs[indexPath.section] as! NSMutableArray)[indexPath.row] as! UserInfo
            let imadata = NSData(base64Encoded: (deviceInfo.deviceIma == nil) ? "":deviceInfo.deviceIma!, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
            var iamge: UIImage? = UIImage(data: imadata! as Data)
            if iamge == nil {
                iamge = #imageLiteral(resourceName: "icon_img_3")
            }
            cell?.headIma.image = iamge?.drawCornerIma(Sise: nil)
            cell?.titLab.text = deviceInfo.deviceName! + (Localizeable(key: "的表") as String)
            if Defaultinfos.getIntValueForKey(key: revertNum) > 0 {
                cell?.notiLab.isHidden = false
            }
            guard let mesArr = detailArrs[2] as? NSMutableArray, let messArr = mesArr[indexPath.row] as? NSMutableArray, let dic = messArr.lastObject as? NSDictionary, let time = dic["DATE"] as? String else{
                cell?.timeLab.text = ""
                guard let mesArr = detailArrs[2] as? NSMutableArray,let messArr = mesArr[indexPath.row] as? NSMutableArray, let dic = messArr.lastObject as? NSDictionary, let mess = dic["MESSAGE"] as? String else{
                    cell?.messLab.text = "暂无信息"
                    return cell!
                }
                cell?.messLab.text = mess
                return cell!
            }
            let b = NSMutableCharacterSet(charactersIn:" ")
            b.addCharacters(in: "/")
            let dateS = time.components(separatedBy: b as CharacterSet)
            cell?.timeLab.text = String.init(format: "%@", dateS[3])
            
            guard let mesArr0 = detailArrs[2] as? NSMutableArray,let messArr0 = mesArr0[indexPath.row] as? NSMutableArray, let dic0 = messArr0.lastObject as? NSDictionary, let mess0 = dic0["MESSAGE"] as? String else{
                cell?.messLab.text = "暂无信息"
                return cell!
            }
            cell?.messLab.text = mess0
            return cell!
            
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? MessTableViewCell
        let mesDetailVC = MssDetailTableViewController(nibName: "MssDetailTableViewController", bundle: nil)
        if indexPath.section == 0 && indexPath.row == 0 {
            mesDetailVC.messType = 1
            mesDetailVC.title = Localizeable(key: "报警消息") as String
             Defaultinfos.putKeyWithInt(key: warningNum, value: 0)
        }
        if indexPath.section == 0 && indexPath.row == 1 {
            mesDetailVC.messType = 3
            mesDetailVC.title = Localizeable(key: "申请消息") as String
             Defaultinfos.putKeyWithInt(key: applyForNum, value: 0)
        }
        if indexPath.section == 1 {
            let deviceInfo = (messArrs[indexPath.section] as! NSMutableArray)[indexPath.row] as! UserInfo
            mesDetailVC.messType = 999
            mesDetailVC.title = deviceInfo.deviceName! + (Localizeable(key: "的表") as String)
            mesDetailVC.deviceID = deviceInfo.deviceId
            mesDetailVC.devicePh = deviceInfo.devicePh
            Defaultinfos.putKeyWithInt(key: revertNum, value: 0)
        }
        cell?.notiLab.isHidden = true
        let notNum = Defaultinfos.getIntValueForKey(key: warningNum)
        let applyNum = Defaultinfos.getIntValueForKey(key: applyForNum)
        let reverNum = Defaultinfos.getIntValueForKey(key: revertNum)
        self.navigationController?.tabBarItem.badgeValue = String.init(format: "%d", notNum + applyNum + reverNum)
        if notNum + applyNum + reverNum == 0{
            self.navigationController?.tabBarItem.badgeValue = nil
        }
        mesDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(mesDetailVC, animated: true)
        
    }
    
}
