//
//  AddFamilyViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/5/14.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class AddFamilyViewController: UIViewController {
    @IBOutlet var relationFile: UITextField!
    @IBOutlet var phoneFile: UITextField!
    @IBOutlet var permissionsFile: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
     title = Localizeable(key: "完善家人信息") as String
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confimSelect(_ sender: UIButton) {
        if relationFile.text == "" {
            MBProgressHUD.showError(Localizeable(key: "请输入关系")as String)
            return
        }
        if phoneFile.text == "" {
            MBProgressHUD.showError(Localizeable(key: "请输入手机号码")as String)
            return
        }
        MBProgressHUD.showMessage(Localizeable(key: "正在邀请...") as String!)
        let user = UnarchiveUser()
       let requestDic = RequestKeyDic()
        requestDic.addEntries(from: [  "Phone": "phoneFile.text",
                                       "RelationName": "relationFile.text",
                                       "DeviceId": StrongGoString(object: user?.deviceId),
                                       "UserId": (user?.userId)!,])
        MyHttpSessionMar.shared.post(Prefix + "api/User/InviteUser", parameters: requestDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, request) in
            MBProgressHUD.hide()
            let resultDic = request as! Dictionary<String, Any>
            if resultDic["State"] as! Int == 0 || resultDic["State"] as! Int == 8000{
                print("resultDic  \(resultDic)")
                MBProgressHUD.showSuccess(Localizeable(key: "邀请成功") as String)
                 DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else{
               MBProgressHUD.showError(resultDic["Message"] as! String)
            }
        }) { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            MBProgressHUD.showError(Error.localizedDescription)
        }
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
