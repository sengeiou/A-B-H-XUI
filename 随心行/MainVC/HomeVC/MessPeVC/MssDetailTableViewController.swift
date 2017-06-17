//
//  MssDetailTableViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/6/8.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class MssDetailTableViewController: UITableViewController {
    var itemsArr: Array<Dictionary<String, Any>>! = []
    var messHeigh: NSMutableArray! = []
    var formatter: DateFormatter!
    var formatter1: DateFormatter!
    var deviceID: String!
    var devicePh: String!
    lazy var user: UserInfo = {
        let user = UnarchiveUser()
        return user!
    }()
    lazy var fmdbase: FMDbase = {
        let fmdbase = FMDbase.shared()
        return fmdbase
    }()
    var messType: Int = 1
    var mesPage: Int! = 1
    var oldMesPage: Int! = 1
    var false1: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMethod(update: false)
        createUI()
        setupRefrish()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeMethod(update: Bool) {
        let requDic = RequestKeyDic()
        if !update {
            MBProgressHUD.showMessage(Localizeable(key: "正在查询...") as String)
        }
        
        if messType == 1 {
            requDic.addEntries(from: ["Id": user.userId!,
                                      "PageNo": mesPage,
                                      "PageCount": 10,
                                      "TypeID": 0,
                                      "DataCode": "",
                                      "UserID": user.userId!,
                                      "Exclude": ""])
            print(requDic)
            let httpMgr = MyHttpSessionMar.shared
            httpMgr.post(Prefix + "api/ExceptionMessage/ExcdeptionListWhitoutCode", parameters: requDic, progress: { (Progress) in
                
            }, success: { (URLSessionDataTask, result) in
                if !update {
                    MBProgressHUD.hide()
                }
                if update{
                    self.tableView.isScrollEnabled = true
                    self.tableView.mj_footer.endRefreshing()
                }
                guard let itemDic = result as? NSDictionary, let items = itemDic["Items"] as? NSArray else{
                    return
                }
                 if items.count < 10 && self.oldMesPage != requDic["PageNo"] as! Int{
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                else{
                    self.tableView.mj_footer.isHidden = false
                }
                self.toCalculateMess(dictions: items as! Array<Any>)
            }) { (URLSessionDataTask, Error) in
                if !update {
                    MBProgressHUD.hide()
                    MBProgressHUD.showError(Error.localizedDescription)
                }
                else{
                    self.tableView.isScrollEnabled = true
                    self.tableView.mj_footer.endRefreshing()
                }
            }
        }
        else if messType == 3{
            requDic.addEntries(from: ["UserId": user.userId!])
            print(requDic)
            let httpMgr = MyHttpSessionMar.shared
            httpMgr.post(Prefix + "api/AuthShare/RequestList", parameters: requDic, progress: { (Progress) in
                
            }, success: { (URLSessionDataTask, result) in
                if !update {
                    MBProgressHUD.hide()
                }
                if update{
                    self.tableView.isScrollEnabled = true
                    self.tableView.mj_footer.endRefreshing()
                }
                guard let itemDic = result as? NSDictionary, let items = itemDic["Items"] as? NSArray else{
                    return
                }
                print("申请消息：\(itemDic)")
                self.toCalculateMess(dictions: items as! Array<Any>)
            }) { (URLSessionDataTask, Error) in
                if !update {
                    MBProgressHUD.hide()
                    MBProgressHUD.showError(Error.localizedDescription)
                }
                else{
                    self.tableView.isScrollEnabled = true
                    self.tableView.mj_footer.endRefreshing()
                }
            }
        }
        else {
            requDic.addEntries(from: ["DeviceID": deviceID,
                                      "PageNo": mesPage,
                                      "PageCount": 10,
                                      "AppPhone": user.userPh!,
                                      "Type": 0
                                      ])
            print(requDic)
            let httpMgr = MyHttpSessionMar.shared
            httpMgr.post(Prefix + "api/Device/SelectDeviceBills", parameters: requDic, progress: { (Progress) in
                
            }, success: { (URLSessionDataTask, result) in
                if !update {
                    MBProgressHUD.hide()
                }
                if update{
                    self.tableView.isScrollEnabled = true
                    self.tableView.mj_footer.endRefreshing()
                }
                guard let itemDic = result as? NSDictionary, let items = itemDic["List"] as? NSArray else{
                    return
                }
                print("self.oldMesPage  \(self.oldMesPage)  \n requDic[PageNo] as! Int \(requDic["PageNo"] as! Int) \n items.count  \(items.count) ")
                if items.count < 10 && self.oldMesPage != requDic["PageNo"] as! Int{
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                else{
                    self.tableView.mj_footer.isHidden = false
                }
                print(items)
                self.toCalculateMess(dictions: items as! Array<Any>)
            }) { (URLSessionDataTask, Error) in
                if !update {
                    MBProgressHUD.hide()
                    MBProgressHUD.showError(Error.localizedDescription)
                }
                else{
                    self.tableView.isScrollEnabled = true
                   self.tableView.mj_footer.endRefreshing()
                }
            }
        }
    }
    
    func createUI()  {
        if messType == 1 {
            self.title = Localizeable(key: "报警消息") as String
        }
        if messType == 3 {
            self.title = Localizeable(key: "申请消息") as String
        }
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    
    func toCalculateMess(dictions: Array<Any>) {
        formatter = DateFormatter()
        if messType == 1{
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
        }
        else if messType == 3{
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        }
        else{
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        }
        let zone = TimeZone(secondsFromGMT: 0)
        formatter.timeZone = zone
        
        formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy/MM/dd HH:mm"
        let timeZone1 = NSTimeZone.system
        let interval1 = timeZone1.secondsFromGMT()
        let zone1 = TimeZone(secondsFromGMT: interval1/3600)
        formatter1.timeZone = zone1
        var found  = false
//        var dates: Array<Dictionary<String, String>> = []
        for mesDic in dictions {
            let diction  = NSMutableDictionary(dictionary: mesDic as! Dictionary)
            let labWith = MainScreen.width - 78 - 5 - 15 - 8 - 8
            var messRect: CGRect
            if messType == 999 {
                 messRect = MessMode.putMessRect(mess: StrongGoString(object: diction["BillContent"]) as NSString, mesRect: CGSize(width: labWith, height: 1000), dic: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
            }
            else{
                 messRect = MessMode.putMessRect(mess: StrongGoString(object: diction["Message"]) as NSString, mesRect: CGSize(width: labWith, height: 1000), dic: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
            }
            var date = ""
            if messType == 1{
                date = diction["DeviceDate"] as! String
            }
            else if messType == 3{
                date = diction["Created"] as! String
            }
            else{
                date = diction["CreateTime"] as! String
            }
            let date1 = formatter.date(from: date)
            let dateTime = getNowDateFromatAnDate(anyDate: date1!)
            let nowTimeStr = formatter1.string(from: dateTime)
            let b = NSMutableCharacterSet(charactersIn:" ")
            b.addCharacters(in: "/")
            let dateS = nowTimeStr.components(separatedBy: b as CharacterSet)
            diction.addEntries(from: ["DATE": String.init(format: "%@/%@", dateS[1],dateS[2])])
            diction.addEntries(from: ["TIME": String.init(format: "%@", dateS[3])])
//            if messType == 1{
//                let baseDic = ["USERID": self.user.userId!,"DEVICEID": StrongGoString(object: diction["DeviceID"]),"DATE": nowTimeStr,"TYPE": String.init(format: "%d", messType),"EXTYPE": StrongGoString(object: diction["NotificationType"]),"MESSAGE":StrongGoString(object: diction["Message"]),"HANDLE": "0"]
//                dates.append(baseDic)
//            }
//            else if messType == 3{
//                let baseDic = ["USERID": self.user.userId!,"DEVICEID": StrongGoString(object: diction["DeviceId"]),"DATE": nowTimeStr,"TYPE": String.init(format: "%d", messType),"EXTYPE": "0","MESSAGE":StrongGoString(object: diction["Info"]),"HANDLE": StrongGoString(object: diction["Status"])]
//                dates.append(baseDic)
//            }
//            else {
//                let baseDic = ["USERID": self.user.userId!,"DEVICEID": deviceID!,"DATE": nowTimeStr,"TYPE": String.init(format: "%d", messType),"EXTYPE": "0","MESSAGE":StrongGoString(object: diction["BillContent"]),"HANDLE":"0"]
//                dates.append(baseDic)
//
//                print("mesDic  \(mesDic)  (((+  \(diction)")
//            }
            let b1 = self.itemsArr.contains(where: { (element) -> Bool in
                if messType == 1{
                    if element["DeviceDate"] as! String == diction ["DeviceDate"] as! String{
                        return true
                    }else {
                        return false
                    }
                }
                else if messType == 3{
                    if element["Created"] as! String == diction ["Created"] as! String{
                        return true
                    }else {
                        return false
                    }
                }
                else{
                    if element["CreateTime"] as! String == diction ["CreateTime"] as! String{
                        return true
                    }else {
                        return false
                    }
                }
            })
            if !b1 {
                self.itemsArr.append(diction as! Dictionary<String, Any>)
                messHeigh.add(messRect)
                if !found {
                    found = true
                    self.oldMesPage = self.mesPage
                    self.mesPage! += 1
                }
            }
        }
        
        for insDas in self.itemsArr.reversed() {
            var date = ""
            if messType == 1{
                date = insDas["DeviceDate"] as! String
            }
            else if messType == 3{
                date = insDas["Created"] as! String
            }
            else{
                date = insDas["CreateTime"] as! String
            }
            let date1 = formatter.date(from: date)
            let dateTime = getNowDateFromatAnDate(anyDate: date1!)
            let nowTimeStr = formatter1.string(from: dateTime)
            var baseDic:Dictionary<String, Any>
            if messType == 1{
                 baseDic = ["USERID": self.user.userId!,"DEVICEID": StrongGoString(object: insDas["DeviceID"]),"DATE": nowTimeStr,"TYPE": String.init(format: "%d", messType),"EXTYPE": StrongGoString(object: insDas["NotificationType"]),"MESSAGE":StrongGoString(object: insDas["Message"]),"HANDLE": "0"]
            }
            else if messType == 3{
                 baseDic = ["USERID": self.user.userId!,"DEVICEID": StrongGoString(object: insDas["DeviceId"]),"DATE": nowTimeStr,"TYPE": String.init(format: "%d", messType),"EXTYPE": "0","MESSAGE":StrongGoString(object: insDas["Info"]),"HANDLE": StrongGoString(object: insDas["Status"])]
            }
            else {
                 baseDic = ["USERID": self.user.userId!,"DEVICEID": deviceID!,"DATE": nowTimeStr,"TYPE": String.init(format: "%d", messType),"EXTYPE": "0","MESSAGE":StrongGoString(object: insDas["BillContent"]),"HANDLE":"0"]
            }
            fmdbase.insertMess(messDic: baseDic)
        }
        print("mesrect \(messHeigh)  \n ))) \(self.itemsArr)")
        DispatchQueue.main.async { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    func setupRefrish(){
        
        let footer = MJRefreshAutoNormalFooter { 
            self.footRereshing()
        }
        footer?.setTitle("点击或上拉可以刷新", for: .idle)
        footer?.setTitle("刷新中...", for: .refreshing)
        footer?.setTitle("无更多数据", for: .noMoreData)
        self.tableView.mj_footer = footer
        self.tableView.mj_footer.isHidden = true
    }
    
    func footRereshing(){
        self.tableView.isScrollEnabled = false
        initializeMethod(update: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArr.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rect = messHeigh[indexPath.row] as! CGRect
        var offset:CGFloat = 0
        if rect.size.height > 48.5 {
            offset = rect.size.height - CGFloat(48.5)
        }
        return CGFloat(200) + offset
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MESSDETAILCELL")  as? MessDetailTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("MessDetailTableViewCell", owner: self, options: nil)?.last as? MessDetailTableViewCell
        }
        cell?.selectionStyle = .none
        var dic = itemsArr[indexPath.row]
        let str = dic["Avatar"] as? String
        if str != nil {
            cell?.headIma.sd_setImage(with: URL(string: dic["Avatar"] as! String), placeholderImage: #imageLiteral(resourceName: "icon_pu"))
        }
        else{
//            let imadata = NSData(base64Encoded: self.user.deviceIma!, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
//            let iamge: UIImage? = UIImage(data: imadata! as Data)
//            if iamge == nil {
                cell?.headIma.image = #imageLiteral(resourceName: "icon_pu")
//            }
//            else{
//                cell?.headIma.image = iamge
//            }
        }
        cell?.dateLab.text = StrongGoString(object: dic["DATE"])
        cell?.timeLab.text = StrongGoString(object: dic["TIME"])
        
        if messType == 1 {
            cell?.messLab.text = StrongGoString(object: dic["Message"])
        }
        else if messType == 3{
            cell?.messLab.text = StrongGoString(object: dic["Info"])
            cell?.messStype = messType
            cell?.status = dic["Status"] as! Int
            cell?.selectClosureWithBut(closure: { (tag) in
                let requDic = RequestKeyDic()
                MBProgressHUD.showMessage(Localizeable(key: "正在处理...") as String)
                requDic.addEntries(from: ["RequestId": StrongGoString(object: dic["RequestId"]),
                                          "TypeId": tag! - 100])
                MyHttpSessionMar.shared.post(Prefix + "api/AuthShare/Process", parameters: requDic, progress: { (Progress) in
                    
                }, success: { (URLSessionDataTask, result) in
                    let resultDic = result as! Dictionary<String, Any>
                    MBProgressHUD.hide()
                    if resultDic["State"] as! Int == 0{
                        if tag == 102{
                            dic["Status"] = 2
                        }
                        else{
                            dic["Status"] = 1
                        }
                        print(dic)
                        let date = dic["Created"] as! String
                        let date1 = self.formatter.date(from: date)
                        let dateTime = getNowDateFromatAnDate(anyDate: date1!)
                        let nowTimeStr = self.formatter1.string(from: dateTime)
                        let baseDic = ["USERID": self.user.userId!,"DEVICEID": StrongGoString(object: dic["DeviceId"]),"DATE": nowTimeStr,"TYPE": String.init(format: "%d", self.messType),"EXTYPE": "0","MESSAGE":StrongGoString(object: dic["Info"]),"HANDLE": StrongGoString(object: dic["Status"])]
                        self.fmdbase.insertMess(messDic: baseDic)
                        
                        let b1 = self.itemsArr.contains(where: { (element) -> Bool in
                            if element["Created"] as! String == dic ["Created"] as! String{
                                return true
                            }else {
                                return false
                            }
                        })
                        
                        if b1{
                            let index = self.itemsArr.index(where: { (element) -> Bool in
                                if element["Created"] as! String == dic ["Created"] as! String{
                                    return true
                                }else {
                                    return false
                                }
                            })
                            if (index != nil) {
                                self.itemsArr[index!] = dic
                            }
                        }
                        self.tableView.reloadData()
                        print(self.itemsArr)
                    }
                    else{
                        MBProgressHUD.showError(Localizeable(key: "处理失败") as String)
                    }
                }, failure: { (URLSessionDataTask, Error) in
                    MBProgressHUD.hide()
                    MBProgressHUD.showError(Error.localizedDescription)
                })
            })
        }
        else{
             cell?.messLab.text = StrongGoString(object: dic["BillContent"])
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if messType == 999 {
            let urlStr = "tel://" + devicePh
            if let url = URL(string: urlStr){
                if #available(iOS 10, *){
                    UIApplication.shared.open(url, options: [:], completionHandler: { (Bool) in
                        
                    })
                }else{
                    UIApplication.shared.openURL(url)
                }
            }
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
