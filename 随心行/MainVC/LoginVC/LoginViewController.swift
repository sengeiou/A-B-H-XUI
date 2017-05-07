//
//  LoginViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/7.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var accFie: UITextField!
    @IBOutlet weak var passFie: UITextField!
    @IBOutlet weak var findPassBut: UIButton!
    @IBOutlet weak var resignBut: UIButton!
    @IBOutlet weak var loginBut: UIButton!
    @IBOutlet weak var headTop: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMehod()
        createUI()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics(rawValue: 0)!)
        navigationController?.navigationBar.isTranslucent = true
        extendedLayoutIncludesOpaqueBars = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage.ImageWithColor(color: ColorFromRGB(rgbValue: 0x389aff), size: CGSize(width: MainScreen.width, height: 64)), for: UIBarMetrics(rawValue: 0)!)
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func createUI() {
        accFie.delegate = self
        passFie.delegate = self
    }
    
    func initializeMehod() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(not:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(not:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func findPassSelect(){
        let changePasVC = ResignViewController(nibName: "ResignViewController", bundle: nil)
        changePasVC.changePass = true
        navigationController?.pushViewController(changePasVC, animated: true)
    }
    
    @IBAction func resignSelect(_ sender: UIButton) {
        navigationController?.pushViewController(ResignViewController(nibName: "ResignViewController", bundle: nil), animated: true)
        
        //         self.navigationController?.pushViewController(DeviceInfoViewController(nibName: "DeviceInfoViewController", bundle: nil), animated: true)
    }
    
    @IBAction func loginSelect(_ sender: UIButton) {
        
        Defaultinfos.removeValueForKey(key: AccountToken)
        if accFie.text == "" {
            MBProgressHUD.showError(Localizeable(key: "请输入手机号") as String!)
            return
        }
        if passFie.text == "" {
            MBProgressHUD.showError(Localizeable(key: "请输入密码") as String!)
            return
        }
        
        MBProgressHUD.showMessage(Localizeable(key: "登录中...") as String!)
        let httpMar = MyHttpSessionMar.shared
        let requDic = RequestKeyDic()
        requDic.addEntries(from: ["Name":accFie.text!, "Pass":passFie.text!,"LoginType":"0"])
        
        httpMar.post(Prefix + "api/User/Login", parameters: requDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            let resultDic = result as! Dictionary<String, Any>
            print("返回 \(resultDic)")
            
            if resultDic["State"] as! Int == 1000{
                MBProgressHUD.hide()
                MBProgressHUD.showError(Localizeable(key: "账号密码不正确") as String!)
            }
            else if resultDic["State"] as! Int == 0{
                
                let userDic = (resultDic["Item"]) as! Dictionary<String, AnyObject>
                print("登录返回 \(userDic)")
                
                let user = getNewUser()
                //                if(user == nil) {
                //                    user = getNewUser()
                //                }
                user.userId = StrongGoString(object: userDic["UserId"]  as! Int)
                user.userPh = StrongGoString(object: userDic["LoginName"])
                user.userName = StrongGoString(object: userDic["Username"])
                print("string = \(StrongGoString(object: userDic["Avatar"]))")
                // print(URL(string: userDic["Avatar"] as! String)!)
                var url = StrongGoString(object: userDic["Avatar"] as AnyObject)
                if url == ""{
                    url = "0"
                }
                downloadedFrom(url: URL(string: url)!) { (Image) in
                    user.userIma = UIImageJPEGRepresentation(Image, 1)?.base64EncodedString()
                    print("image \(Image)  data \(String(describing: UIImageJPEGRepresentation(Image, 1)?.base64EncodedString()))")
                    
                    Defaultinfos.putKeyWithNsobject(key: Account, value: self.accFie.text!)
                    Defaultinfos.putKeyWithNsobject(key: AccountToken, value: resultDic["AccessToken"]!)
                    
                    let timeZone = NSTimeZone.system
                    let interval = timeZone.secondsFromGMT()
                    
                    let requestDic = RequestKeyDic()
                    requestDic.addEntries(from: ["UserId": (user.userId)!,
                                                 "GroupId": "",
                                                 "MapType": "",
                                                 "LastTime": Date().description,
                                                 "TimeOffset": NSNumber(integerLiteral: interval/3600),
                                                 "Token": resultDic["AccessToken"]!])
                    print("requestDic \(requestDic) frb  \(interval)")
                    httpMar.post(Prefix + "api/Device/PersonDeviceList", parameters: requestDic, progress: { (Progress) in
                        
                    }, success: { (URLSessionDataTask, result) in
                        
                        let resultDic = result as! Dictionary<String, Any>
                        if resultDic["State"] as! Int == 100{
                            DispatchQueue.main.async() { () -> Void in
                                MBProgressHUD.hide()
                                MBProgressHUD.showSuccess(Localizeable(key: "登录成功") as String!)
                            }
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
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
                            }
                            return
                        }
                        
                        let items:Array<Dictionary<String, Any>> = resultDic["Items"] as! Array<Dictionary<String, Any>>
                        for i in 0...(items.count - 1){
                            print("i== \(i)   itemcount = \(items.count)")
                            let itemDic = items[i]
                            var itemUser = getNewUser()
                            if i == 0{
                                itemUser = user
                            }
                            itemUser.userId = user.userId
                            itemUser.deviceId = StrongGoString(object: itemDic["Id"] as! Int)
                            itemUser.devicePh = StrongGoString(object: itemDic["Sim"])
                            itemUser.deviceName = StrongGoString(object: itemDic["NickName"])
                            //                            itemUser.relatoin = ""
                            var url = StrongGoString(object: userDic["Avatar"])
                            if url == ""{
                                url = "0"
                            }
                            downloadedFrom(url: URL(string: url)!, callBack: { (Image) in
                                var imaData: String? = UIImageJPEGRepresentation(Image, 1)?.base64EncodedString()
                                if imaData == nil{
                                    imaData = ""
                                }
                                itemUser.userIma = imaData
                                print("返回设备列表数据  \(itemUser) data = \(String(describing: UIImageJPEGRepresentation(Image, 1)?.base64EncodedString()))")
                                let fmbase = FMDbase.shared()
                                logUser(user: itemUser)
                                fmbase.insertUserInfo(userInfo: itemUser)
                                if i == 0{
                                    ArchiveRoot(userInfo: itemUser)
                                }
                                if i == (items.count - 1){
                                    DispatchQueue.main.async() { () -> Void in
                                        MBProgressHUD.hide()
                                        MBProgressHUD.showSuccess(Localizeable(key: "登录成功") as String!)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
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
                                    }
                                }
                            })
                        }
                        print("返回 \(resultDic) items \(items)")
                    }, failure: { (URLSessionDataTask, Error) in
                        MBProgressHUD.hide()
                        MBProgressHUD.showError(Error.localizedDescription)
                    })
                    
                }
            }
            else{
                if (resultDic["Message"] != nil){
                    MBProgressHUD.showError(resultDic["Message"] as! String)
                }
            }
        }) { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(Error.localizedDescription)
        }
    }
    
    func keyboardWillShow(not:Notification){
        // 1.取出键盘的frame
        //       let keyBoardF = not.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        // 2.取出键盘弹出的时间
        let duration = not.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -100)
        }
    }
    
    func keyboardWillHidden(not:Notification){
        let duration = not.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.view.transform = CGAffineTransform.identity
        }
    }
}

