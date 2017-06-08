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
    lazy var user: UserInfo = {
        let user = UnarchiveUser()
        return user!
    }()
    var messType: Int! = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMethod()
        createUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeMethod() {
        let requDic = RequestKeyDic()
        MBProgressHUD.showMessage(Localizeable(key: "正在查询...") as String)
        if messType == 1 {
            requDic.addEntries(from: ["Id": user.userId!,
                                      "PageNo": 1,
                                      "PageCount": 10,
                                      "TypeID": 0,
                                      "DataCode": "",
                                      "UserID": user.userId!,
                                      "Exclude": ""])
            let httpMgr = MyHttpSessionMar.shared
            httpMgr.post(Prefix + "api/ExceptionMessage/ExcdeptionListWhitoutCode", parameters: requDic, progress: { (Progress) in
                
            }, success: { (URLSessionDataTask, result) in
                MBProgressHUD.hide()
                guard let itemDic = result as? NSDictionary, let items = itemDic["Items"] as? NSArray else{
                    return
                }
                self.toCalculateMess(dictions: items as! Array<Any>)
            }) { (URLSessionDataTask, Error) in
                MBProgressHUD.hide()
                MBProgressHUD.showError(Error.localizedDescription)
            }
        }
    }
    
    func createUI()  {
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    
    func toCalculateMess(dictions: Array<Any>) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let zone = TimeZone(secondsFromGMT: 0)
        formatter.timeZone = zone
        
        
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy/MM/dd HH:mm"
        let timeZone1 = NSTimeZone.system
        let interval1 = timeZone1.secondsFromGMT()
        let zone1 = TimeZone(secondsFromGMT: interval1/3600)
        formatter1.timeZone = zone1
        
        for mesDic in dictions {
            let diction  = NSMutableDictionary(dictionary: mesDic as! Dictionary)
            let labWith = MainScreen.width - 78 - 5 - 15 - 8 - 8
            let messRect = MessMode.putMessRect(mess: StrongGoString(object: diction["Message"]) as NSString, mesRect: CGSize(width: labWith, height: 1000), dic: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)])
            let date = diction["DeviceDate"]
            let date1 = formatter.date(from: date as! String)
            let dateTime = getNowDateFromatAnDate(anyDate: date1!)
            let nowTimeStr = formatter1.string(from: dateTime)
            let b = NSMutableCharacterSet(charactersIn:" ")
            b.addCharacters(in: "/")
            let dateS = nowTimeStr.components(separatedBy: b as CharacterSet)
            diction.addEntries(from: ["DATE": String.init(format: "%@/%@", dateS[1],dateS[2])])
            diction.addEntries(from: ["TIME": String.init(format: "%@", dateS[3])])
            self.itemsArr.append(diction as! Dictionary<String, Any>)
            messHeigh.add(messRect)
            print("mesrect \(messHeigh)  \n ))) \(self.itemsArr)")
        }
        DispatchQueue.main.async { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    func setupRefrish(){
//        self.tableView.addh
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        let dic = itemsArr[indexPath.row]
        cell?.headIma.sd_setImage(with: URL(string: dic["Avatar"] as! String), placeholderImage: #imageLiteral(resourceName: "icon_pu"))
        cell?.dateLab.text = StrongGoString(object: dic["DATE"])
        cell?.timeLab.text = StrongGoString(object: dic["TIME"])
        cell?.messLab.text = StrongGoString(object: dic["Message"])
        return cell!
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
