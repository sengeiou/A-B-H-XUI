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
        
    }
    
    @IBAction func resignSelect(_ sender: UIButton) {
        navigationController?.pushViewController(ResignViewController(nibName: "ResignViewController", bundle: nil), animated: true)
    }
    
    @IBAction func loginSelect(_ sender: UIButton) {
        
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

