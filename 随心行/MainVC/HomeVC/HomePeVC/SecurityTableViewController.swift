//
//  SecurityTableViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/23.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class SecurityTableViewController: UITableViewController {
    var securitys: NSArray = []
    var deviceLocation: CLLocationCoordinate2D?
    lazy var userInfo: UserInfo = {
        let userInfo = UnarchiveUser()
        return userInfo!
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMethod()
        createUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func createUI() {
        tableView.tableFooterView = UIView()
        title = Localizeable(key: "安全区域") as String
        navigationItem.rightBarButtonItem = UIBarButtonItem.buttonWithItem(target: self, butIma: #imageLiteral(resourceName: "ic_add"), frame: CGRect(x: 0, y: 0, width: 40, height: 40), action: #selector(addSecurity))
    }
    
    func addSecurity() {
        let securityVC = SecurityViewController(nibName: "SecurityViewController", bundle: nil)
        securityVC.addDeviceCen = deviceLocation
        self.navigationController?.pushViewController(securityVC, animated: true)
    }
    
    func initializeMethod() {
        let httpMgr = MyHttpSessionMar.shared
        let requestDic = RequestKeyDic()
        requestDic.addEntries(from: ["DeviceId": userInfo.deviceId!,
                                     "MapType": "AMap"])
        httpMgr.post(Prefix + "api/Geofence/GeofenceList", parameters: requestDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            print(result!)
            let items:NSArray = (result as! NSDictionary)["Items"] as! NSArray
            if items.count > 0{
                self.securitys = items
            }
            self.tableView.reloadData()
        }) { (URLSessionDataTask, Error) in
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return securitys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SECURITYCELL") as? SecurityTableViewCell
        if cell == nil {
           cell = Bundle.main.loadNibNamed("SecurityTableViewCell", owner: self, options: nil)?.last as? SecurityTableViewCell
        }
        cell?.titLab.text = (securitys[indexPath.row] as! NSDictionary).object(forKey: "FenceName") as? String
        cell?.subLab.text = (securitys[indexPath.row] as! NSDictionary).object(forKey: "Description") as? String
        cell?.scopeLab.text = String.init(format: "方圆%d米", ((securitys[indexPath.row] as! NSDictionary).object(forKey: "Radius") as? Int)!)
        cell?.selectionStyle = .none
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let securityVC = SecurityViewController(nibName: "SecurityViewController", bundle: nil)
        self.navigationController?.pushViewController(securityVC, animated: true)
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
