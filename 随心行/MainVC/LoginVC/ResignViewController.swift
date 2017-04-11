//
//  ResignViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/7.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit
import AFNetworking

class ResignViewController: UIViewController, UITextFieldDelegate {
    fileprivate var second: Int = 60
    fileprivate var timer: Timer!
    
    @IBOutlet weak var accTexfild: UITextField!
    @IBOutlet weak var passFild: UITextField!
    @IBOutlet weak var againFild: UITextField!
    @IBOutlet weak var codeFild: UITextField!
    @IBOutlet weak var resignBut: UIButton!
    @IBOutlet weak var protocolBut: UIButton!
    @IBOutlet weak var codeBut: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createUI()
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
    }
    
    func createUI() {
        title = Localizeable(key: "创建账号") as String
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
        codeFild.becomeFirstResponder()
        let httpMar = MyHttpSessionMar.shared
        let parameters:Dictionary<String,String> = ["Phone":accTexfild.text!,"VildateSence":"2","Token":"","Language":systLanage(),"AppId":"71"]
        print( parameters);
        print(Prefix+"api/User/SendSMSCode")
        MBProgressHUD.showMessage(Localizeable(key: "正在发送") as String!)
        httpMar.post(Prefix+"api/User/SendSMSCodeByYunPian", parameters: parameters, progress: { (Progress) in
            
        }, success: { (task, result) in
            let dic = result as! NSDictionary
            if dic["State"] as! Int == 0{
                MBProgressHUD.hide()
                MBProgressHUD.showSuccess(Localizeable(key: "发送成功")as String!)
                if (self.timer != nil) {
                    self.timer.invalidate()
                    self.timer = nil;
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
    
    func timerOut() {
        second -= 1
        codeBut.setTitle(String.init(format: "%d s", second) as String, for: UIControlState.normal)
        if second == 0 {
            self.timer.invalidate()
            self.timer = nil;
            codeBut.setTitle(Localizeable(key: "获取验证码") as String, for: UIControlState.normal)
            second = 60
        }
    }
    
    @IBAction func resignSelect(_ sender: UIButton) {
        
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
}
