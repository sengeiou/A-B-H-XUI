//
//  RelationViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/21.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class RelationViewController: UIViewController {

    @IBOutlet weak var nickNameFile: UITextField!
    @IBOutlet weak var otherFile: UITextField!
    @IBOutlet weak var gaurdainLab: UILabel!
    @IBOutlet weak var requestBut: UIButton!
    var isGuardian: Bool = false
    var relationIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createUI() {
        title = Localizeable(key: "亲属关系") as String
        gaurdainLab.isHidden = isGuardian
        if isGuardian {
            requestBut.setTitle("确认", for: .normal)
        }
        else{
            requestBut.setTitle("发送申请", for: .normal)
        }
        let but = view.viewWithTag(101) as! UIButton
        but.isSelected = true
       let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 30))
       nickNameFile.leftView = leftView
       nickNameFile.leftViewMode = UITextFieldViewMode.always
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func relationSelect(_ sender: UIButton) {
        for i in 0...4 {
            let but = view.viewWithTag(101 + i) as! UIButton
            but.isSelected = false
        }
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            relationIndex = sender.tag - 101
        }
        if sender.tag == 105 {
            if sender.isSelected {
                otherFile.becomeFirstResponder()
            }
            else{
                otherFile.resignFirstResponder()
            }
        }
        else{
            otherFile.resignFirstResponder()
        }
    }
    
    @IBAction func confimSelect(_ sender: UIButton) {
        if nickNameFile.text == "" {
            MBProgressHUD.showError(Localizeable(key: "请输入您的姓名") as String!)
            return;
        }
        if (relationIndex == 4 && otherFile.text == "") {
            MBProgressHUD.showError(Localizeable(key: "请输入关系") as String!)
            otherFile.becomeFirstResponder()
            return;
        }
        let user = UnarchiveUser()!
        let parameterDic = RequestKeyDic()
        MBProgressHUD.showMessage(Localizeable(key: "请求中...") as String)
        print(String(format: "%d", Defaultinfos.getIntValueForKey(key: UserID)),Defaultinfos.getValueForKey(key: Account)!,relationName())
        parameterDic.addEntries(from: ["DeviceId":user.deviceId!,"UserId": String(format: "%d", Defaultinfos.getIntValueForKey(key: UserID)),"RelationPhone":Defaultinfos.getValueForKey(key: Account)!,"RelationName":relationName(),"Info":nickNameFile.text!])
        let httpMar = MyHttpSessionMar.shared
        httpMar.post(Prefix + "api/Device/AddDeviceAndUserGroup", parameters: parameterDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            let dic = result as! Dictionary<NSString, Any>
            print(dic)
            MBProgressHUD.hide()
            if dic["State"] as! Int == 0{
                let fmdbase = FMDbase.shared()
                let newuser = fmdbase.selectUser(userid: user.userId!, deviceid: user.deviceId!)
                newuser?.relatoin = self.relationName()
                fmdbase.insertUserInfo(userInfo: newuser!)
                
                user.userName = self.nickNameFile.text!
                user.relatoin = self.relationName()
                ArchiveRoot(userInfo: user)
                self.navigationController?.pushViewController(DeviceInfoViewController(nibName: "DeviceInfoViewController", bundle: nil), animated: true)
            }
            else if(dic["State"] as! Int == 1500){
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    let homeVC = HomeViewController()
                    homeVC.tabBarItem = UITabBarItem(title: "主页", image: UIImage(named: "tab_home_pre"), tag: 1001)
                    let homeNav = NavViewController(rootViewController: homeVC)
                    
                    let messVC = MessTableViewController(nibName: "MessTableViewController", bundle: nil)
                    messVC.tabBarItem = UITabBarItem(title: "消息", image: UIImage(named: "tab_messg_pre"), tag: 1002)
                    let messNav = NavViewController(rootViewController: messVC)
                    
                    let meVC = MeTableViewController(nibName: "MeTableViewController", bundle: nil)
                    meVC.tabBarItem = UITabBarItem(title: "我的", image: #imageLiteral(resourceName: "tab_mine_pre"), tag: 1003)
                    let meNav = NavViewController(rootViewController: meVC)
                    
                    let tabVC = UITabBarController()
                    tabVC.viewControllers = [homeNav,messNav,meNav]
                    
                    UIApplication.shared.keyWindow?.rootViewController = tabVC
//                }
            }
            else{
                MBProgressHUD.hide()
                MBProgressHUD.showError(dic["Message"] as! String)
            }
        }) { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(Localizeable(key: "申请失败") as String)
        }
    }
    
    func relationName() -> String {
        var relotionStr = ""
        switch relationIndex {
        case 0:
            relotionStr = Localizeable(key: "儿子") as String!
            break;
        case 1:
            relotionStr = Localizeable(key: "女儿") as String!
            break;
        case 2:
            relotionStr = Localizeable(key: "孙子") as String!
            break;
        case 3:
            relotionStr = Localizeable(key: "孙女") as String!
            break;
        default:
            relotionStr = otherFile.text!
            break;
        }
        return relotionStr
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
