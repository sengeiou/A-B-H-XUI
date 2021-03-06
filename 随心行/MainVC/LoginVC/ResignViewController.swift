//
//  ResignViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/7.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit
//import AFNetworking

class ResignViewController: UIViewController, UITextFieldDelegate {
    fileprivate var second: Int = 60
    fileprivate var timer: Timer!
    var changePass: Bool = false
    
    @IBOutlet weak var accTexfild: UITextField!
    @IBOutlet weak var passFild: UITextField!
    @IBOutlet weak var againFild: UITextField!
    @IBOutlet weak var codeFild: UITextField!
    @IBOutlet weak var resignBut: UIButton!
    @IBOutlet weak var protocolBut: UIButton!
    @IBOutlet weak var codeBut: UIButton!
    @IBOutlet weak var protocolLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createUI()
        
        //        let fmdb = FMDbase.shared()
        //        let user = UserInfo()
        //        user.userId = "123456"
        //        user.deviceId = "imed"
        //        user.devicePh = "7894561"
        //        user.deviceIma = "baidu.com1"
        //        user.relatoin = "老大1"
        //        user.userName = "welcome1"
        //        user.userPass = "******1"
        //        user.userIma = "2manhua.com1"
        //        fmdb.insertUserInfo(userInfo: user)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
        super.viewWillDisappear(animated)
        //        let fmdb = FMDbase.shared()
        //        let user = UserInfo()
        //        user.userId = "123456"
        //        user.deviceId = "imed"
        //        fmdb.delegateUser(userInfo: user)
    }
    
    func createUI() {
        Defaultinfos.putKeyWithInt(key: warningNum, value: 0)
        Defaultinfos.putKeyWithInt(key: applyForNum, value: 0)
        Defaultinfos.putKeyWithInt(key: revertNum, value: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActivity(not:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        title = Localizeable(key: "创建账号") as String
        if changePass {
            title = Localizeable(key: "忘记密码") as String
            passFild.placeholder = Localizeable(key: "请输入新密码") as String
            againFild.placeholder = Localizeable(key: "请输入新密码") as String
            protocolLab.isHidden = true
            protocolBut.isHidden = true
            resignBut.setTitle(Localizeable(key: "确认修改") as String, for: .normal)
        }
        accTexfild.delegate = self
        passFild.delegate = self
        againFild.delegate = self
        codeFild.delegate = self
    }
    
    @IBAction func getCodeSelect(_ sender: UIButton) {
        if accTexfild.text == "" {
            MBProgressHUD.showError(Localizeable(key: "请输入手机号") as String!)
            return
        }
        MBProgressHUD.showMessage(Localizeable(key: "正在发送") as String!)
        codeFild.becomeFirstResponder()
        let httpMar = MyHttpSessionMar.shared
        let parameterDic = RequestKeyDic()
        parameterDic.addEntries(from: ["LoginName":accTexfild.text!])
        
        if changePass {
            let parameters:Dictionary<String,String> = ["Phone":"+86" + self.accTexfild.text!,"VildateSence":"1","Token":"","Language":systLanage(),"AppId":"71"]
            print( parameters)
            print(Prefix+"api/User/SendSMSCode")
            httpMar.post(Prefix+"api/User/SendSMSCodeByYunPian", parameters: parameters, progress: { (Progress) in
                
            }, success: { (task, result) in
                let dic = result as! NSDictionary
                if dic["State"] as! Int == 0{
                    MBProgressHUD.hide()
                    MBProgressHUD.showSuccess(Localizeable(key: "发送成功")as String!)
                    if (self.timer != nil) {
                        self.timer.invalidate()
                        self.timer = nil
                    }
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerOut), userInfo: nil, repeats: true)
                    self.codeBut.setTitle("60 s", for: UIControlState.normal)
                    self.codeBut.isEnabled = false
                }
            }) { (tak, error) in
                MBProgressHUD.hide()
                MBProgressHUD.showError(Localizeable(key: "发送失败") as String!)
            }
            return
        }
        parameterDic.addEntries(from: ["Token" : ""])
        print(parameterDic)
        httpMar.post(Prefix + "api/User/CheckUser", parameters: parameterDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            print("URLSessionDataTask  \(result)")
            let resDic = result as! Dictionary<String, Any>
            print(resDic["State"]!)
            if (resDic["State"] as! Int == 0) {
                let parameters:Dictionary<String,String> = ["Phone":"+86" + self.accTexfild.text!,"VildateSence":"1","Token":"","Language":systLanage(),"AppId":"71"]
                print( parameters)
                print(Prefix+"api/User/SendSMSCode")
                httpMar.post(Prefix+"api/User/SendSMSCodeByYunPian", parameters: parameters, progress: { (Progress) in
                    
                }, success: { (task, result) in
                    let dic = result as! NSDictionary
                    if dic["State"] as! Int == 0{
                        MBProgressHUD.hide()
                        MBProgressHUD.showSuccess(Localizeable(key: "发送成功")as String!)
                        if (self.timer != nil) {
                            self.timer.invalidate()
                            self.timer = nil
                        }
                        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerOut), userInfo: nil, repeats: true)
                        self.codeBut.setTitle("60 s", for: UIControlState.normal)
                        self.codeBut.isEnabled = false
                    }
                }) { (tak, error) in
                    MBProgressHUD.hide()
                    MBProgressHUD.showError(Localizeable(key: "发送失败") as String!)
                }
            }
            else{
                MBProgressHUD.hide()
                MBProgressHUD.showError(resDic["Message"] as! String!)
            }
        }) { (DataTask, Error) in
            print("Error  \(Error)")
            MBProgressHUD.hide()
            MBProgressHUD.showError(Error.localizedDescription)
        }
        
    }
    
    func timerOut() {
        second -= 1
        self.codeBut.isEnabled = true
        codeBut.setTitle(String.init(format: "%d s", second) as String, for: UIControlState.normal)
        if second == 0 {
            self.timer.invalidate()
            self.timer = nil
            codeBut.setTitle(Localizeable(key: "获取验证码") as String, for: UIControlState.normal)
            second = 60
        }
    }
    
    @IBAction func resignSelect(_ sender: UIButton) {
        //        navigationController?.pushViewController(BandDeviceViewController(nibName: "BandDeviceViewController", bundle: nil), animated: true)
        //        return
        
        let result : Bool = CheckText(str: passFild.text!)
        print("eiowig \(result)  iwogijoerg  \(passFild.text!)")
        if (accTexfild.text == nil || accTexfild.text == "") {
            MBProgressHUD.showError(Localizeable(key: "请输入手机号") as String!)
            return
        }
        if (passFild.text == "" || againFild.text == "") {
            MBProgressHUD.showError(Localizeable(key: "请输入密码") as String!)
            return
        }
        if passFild.text != againFild.text {
            MBProgressHUD.showError(Localizeable(key: "两次密码不一致") as String!)
            return
        }
        if (codeFild.text == nil || codeFild.text == "") {
            MBProgressHUD.showError(Localizeable(key: "请输入验证码") as String!)
            return
        }
        if !result {
            MBProgressHUD.showError(Localizeable(key: "请输入6-16位字母数字的密码组合") as String!)
            return
        }
        if changePass {
            MBProgressHUD.showMessage(Localizeable(key: "修改中...") as String!)
        }
        else{
            MBProgressHUD.showMessage(Localizeable(key: "注册中...") as String!)
        }
        let httpMar = MyHttpSessionMar.shared
        let parameterDic = RequestKeyDic()
        if changePass {
            parameterDic.addEntries(from: ["LoginName":"+86" + accTexfild.text!,"NewPass":passFild.text!,"SMSCode":codeFild.text!])
            httpMar.post(Prefix + "api/User/ChangePasswordNeedSMSCode", parameters: parameterDic, progress: { (Progress) in
                
            }, success: { (URLSessionDataTask, result) in
                print("loginResult \(result)")
//                MBProgressHUD.hide()
                let resultDic = result as! Dictionary<String, Any>
                if resultDic["State"] as! Int != 0{
                    MBProgressHUD.showError(resultDic["Message"] as! String)
                }
                else{
                    let requDic = RequestKeyDic()
                    requDic.addEntries(from: ["Name":"+86" + self.accTexfild.text!, "Pass":self.passFild.text!,"LoginType":"0"])
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
                                
                                Defaultinfos.putKeyWithNsobject(key: Account, value:"+86" + self.accTexfild.text!)
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
                                        print("44444 \(user.userPh)")
                                        ArchiveRoot(userInfo: user)
                                        Defaultinfos.putKeyWithInt(key: UserID, value: Int(user.userId!)!)
                                        print(Defaultinfos.getIntValueForKey(key: UserID))
                                        JPUSHService.setTags(nil, alias: "U" + user.userId!, callbackSelector: #selector(self.tagsAliasCallback(resCode:tags:alias:)), object: self)
                                        DispatchQueue.main.async() { () -> Void in
                                            MBProgressHUD.hide()
//                                            MBProgressHUD.showSuccess(Localizeable(key: "登录成功") as String!)
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
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
                                    if (items.count > 0){
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
                                            //   itemUser.relatoin = ""
                                            var url = StrongGoString(object: userDic["Avatar"])
                                            if url == ""{
                                                url = "0"
                                            }
                                            downloadedFrom(url: URL(string: url)!, callBack: { (Image) in
                                                var imaData: String? = UIImageJPEGRepresentation(Image, 1)?.base64EncodedString()
                                                if imaData == nil{
                                                    imaData = ""
                                                }
                                                itemUser.deviceIma = imaData
                                                print("返回设备列表数据  \(itemUser) data = \(String(describing: UIImageJPEGRepresentation(Image, 1)?.base64EncodedString()))")
                                                let fmbase = FMDbase.shared()
                                                logUser(user: itemUser)
                                                fmbase.insertUserInfo(userInfo: itemUser)
                                                if i == 0{
                                                    print("55555 \(itemUser.userPh)")
                                                    ArchiveRoot(userInfo: itemUser)
                                                }
                                                if i == (items.count - 1){
                                                    ArchiveRoot(userInfo: user)
                                                    Defaultinfos.putKeyWithInt(key: UserID, value: Int(user.userId!)!)
                                                    print(Defaultinfos.getIntValueForKey(key: UserID))
                                                    JPUSHService.setTags(nil, alias: "U" + user.userId!, callbackSelector: #selector(self.tagsAliasCallback(resCode:tags:alias:)), object: self)
                                                    DispatchQueue.main.async() { () -> Void in
                                                        MBProgressHUD.hide()
//                                                        MBProgressHUD.showSuccess(Localizeable(key: "登录成功") as String!)
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
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
                                    }
                                    print("返回 \(resultDic) items \(items)")
                                }, failure: { (URLSessionDataTask, Error) in
                                    
                                    MBProgressHUD.hide()
                                    if (Error as NSError).code == -999{
                                        return;
                                    }
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
//                    MBProgressHUD.showSuccess(Localizeable(key: "修改成功") as String!)
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
//                        //code
//                        _ = self.navigationController?.popViewController(animated: true)
//                    }
                }
                
            }, failure: { (URLSessionDataTask, Error) in
                MBProgressHUD.hide()
                if (Error as NSError).code == -999{
                    return;
                }
                MBProgressHUD.showError(Error.localizedDescription)
            })
            return
        }
        parameterDic.addEntries(from: ["LoginName":"+86" + accTexfild.text!,"Username":accTexfild.text!,"Email":"","Password":passFild.text!,"SerialNumber":"","Contact":accTexfild.text!,"ContactPhone":"+86 " + accTexfild.text!,"ThirdName":"","ThirdID":"","ThirdType":"","ThirdImg":"","SMSCode":codeFild.text!])
        print("parameterDic\(parameterDic)")
        /*"api/User/Register" 测试注册  正式注册 api/User/RegisterNeedSMSCode*/
        httpMar.post(Prefix + "api/User/RegisterNeedSMSCode", parameters: parameterDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            let string = "string"
            print("string-==== \(string)")
            print("loginResult \(result)")
            let resultDic = result as! Dictionary<String, Any>
            MBProgressHUD.hide()
            if resultDic["State"] as! Int != 0{
                MBProgressHUD.showError(resultDic["Message"] as! String)
            }
            else{
                let user = getNewUser()
                user.userId = String.init(format: "%d", (resultDic["User"]! as! Dictionary<String, Any>)["UserId"]! as! Int)
                user.userPass = self.passFild.text
                user.userPh = self.accTexfild.text
                print("777777 \(user.userPh)")
                ArchiveRoot(userInfo: user)
                JPUSHService.setTags(nil, alias: "U" + user.userId!, callbackSelector: #selector(self.tagsAliasCallback(resCode:tags:alias:)), object: self)
                Defaultinfos.putKeyWithNsobject(key: Account, value:"+86" + self.accTexfild.text!)
                Defaultinfos.putKeyWithNsobject(key: AccountToken, value: resultDic["AccessToken"] as! String)
                print((resultDic["User"]! as! Dictionary<String, Any>)["UserId"]!)
                Defaultinfos.putKeyWithInt(key: UserID, value: (resultDic["User"]! as! Dictionary<String, Any>)["UserId"]! as! Int)
                
                let requestDic = RequestKeyDic()
                let timeZone = NSTimeZone.system
                let interval = timeZone.secondsFromGMT()
                requestDic.addEntries(from: ["UserId": StrongGoString(object: (user.userId)!),
                                             "GroupId": "",
                                             "MapType": "",
                                             "LastTime": Date().description,
                                             "TimeOffset": NSNumber(integerLiteral: interval/3600),
                                             "Token": StrongGoString(object: Defaultinfos.getValueForKey(key: AccountToken))])
                
                httpMar.post(Prefix + "api/Device/PersonDeviceList", parameters: requestDic, progress: { (Progress) in
                    
                }, success: { (URLSessionDataTask, result) in
                    let resultDic = result as! Dictionary<String, Any>
                    let items:Array<Dictionary<String, Any>> = resultDic["Items"] as! Array<Dictionary<String, Any>>
                    if items.count > 0{
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
                    else{
                        self.navigationController?.pushViewController(BandDeviceViewController(nibName: "BandDeviceViewController", bundle: nil), animated: true)
                    }
                }, failure: { (URLSessionDataTask, Error) in
                    MBProgressHUD.hide()
                    if (Error as NSError).code == -999{
                        return;
                    }
                    MBProgressHUD.showError(Error.localizedDescription)
                })
            }
        }) { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(Error.localizedDescription)
        }
    }
    
    @IBAction func protocolSelect(_ sender: UIButton) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == accTexfild {
            passFild.becomeFirstResponder()
        }
        else if textField == passFild{
            againFild.becomeFirstResponder()
        }
        else if textField == againFild{
            codeFild.becomeFirstResponder()
        }
        else{
            view.endEditing(true)
        }
        return true
    }
    
    @objc func tagsAliasCallback(resCode:CInt, tags:NSSet, alias:NSString) {
        print("tagsAliasCallback \(resCode)")
        if resCode != 0 {
            JPUSHService.setTags(nil, aliasInbackground: "U" + (UnarchiveUser()?.userId)!)
        }
    }
    
    func becomeActivity(not:Notification){
        accTexfild.resignFirstResponder()
        passFild.resignFirstResponder()
        againFild.resignFirstResponder()
        codeFild.resignFirstResponder()
    }
}
