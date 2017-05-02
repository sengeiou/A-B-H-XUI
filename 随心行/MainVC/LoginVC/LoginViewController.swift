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
                
                var user = UnarchiveUser()
                if(user == nil) {
                    user = UserInfo()
                }
                user?.userId = StrongGoString(object: userDic["UserId"] as AnyObject)
                user?.userPh = StrongGoString(object: userDic["LoginName"] as AnyObject)
                user?.userName = StrongGoString(object: userDic["Username"] as AnyObject)
                print("string = \(StrongGoString(object: userDic["Avatar"] as AnyObject))")
                //                print(URL(string: userDic["Avatar"] as! String)!)
                var url = StrongGoString(object: userDic["Avatar"] as AnyObject)
                if url == ""{
                    url = "0"
                }
                downloadedFrom(url: URL(string: url)!) { (Image) in
                    user?.userIma = UIImageJPEGRepresentation(Image, 1)?.base64EncodedString()
                    print("image \(Image)  data \(UIImageJPEGRepresentation(Image, 1)?.base64EncodedString())")
                    let fmbase = FMDbase.shared()
                    logUser(user: user!)
                    fmbase.insertUserInfo(userInfo: user!)
                    ArchiveRoot(userInfo: user!)
                    
                    Defaultinfos.putKeyWithNsobject(key: Account, value: self.accFie.text!)
                    Defaultinfos.putKeyWithNsobject(key: AccountToken, value: resultDic["AccessToken"]!)
                    DispatchQueue.main.async() { () -> Void in
                        MBProgressHUD.hide()
                        MBProgressHUD.showSuccess(Localizeable(key: "登录成功") as String!)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                        let homeVC = HomeViewController()
                        homeVC.tabBarItem.title = "首页"
                        homeVC.tabBarItem.selectedImage = UIImage(named: "tab_home_pre")
                        let homeNav = NavViewController(rootViewController: homeVC)
                        
                        let messVC = MessTableViewController(nibName: "MessTableViewController", bundle: nil)
                        messVC.tabBarItem.title = "消息"
                        messVC.tabBarItem.selectedImage = UIImage(named: "tab_messg_pre")
                        let messNav = NavViewController(rootViewController: messVC)
                        
                        let meVC = MeTableViewController(nibName: "MeTableViewController", bundle: nil)
                        meVC.tabBarItem.title = "我的"
//                        meVC.tabBarItem.selectedImage = UIImage(named: "tab_mine_pre")
                        meVC.tabBarItem.selectedImage = #imageLiteral(resourceName: "tab_mine_pre")
                        let meNav = NavViewController(rootViewController: meVC)
                        
                        let tabVC = MainTabViewController()
                        tabVC.viewControllers = [homeNav,messNav,meNav]
                        UIApplication.shared.keyWindow?.rootViewController = tabVC
                    }
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

