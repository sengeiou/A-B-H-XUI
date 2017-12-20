//
//  InputViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/12/11.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

class InputViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidChange(_ textfield: UITextField) {
       
        if  textField.text!.count > 15 {
            let index = textfield.text?.index((textfield.text?.startIndex)!, offsetBy: 15)
            textField.text = textfield.text?.substring(to: index!)
        }
        print("textfield \(textfield.text)")
    }
    
    @IBAction func confimBut(_ sender: Any) {
        if textField.text == ""{
            MBProgressHUD.showError("请输入IMEI码")
            return
        }
        MBProgressHUD.showMessage("")
        let httpMar = MyHttpSessionMar.shared
        let parameterDic = RequestKeyDic()
        parameterDic.addEntries(from: ["SerialNumber":textField.text!,"UserId": String.init(format: "%d", Defaultinfos.getIntValueForKey(key: UserID))])
        print("Defaultinfos.getIntValueForKey(key: UserID)  \(Defaultinfos.getIntValueForKey(key: UserID))")
        print(parameterDic)
        
        httpMar.post(Prefix + "api/Device/CheckDevice", parameters: parameterDic, progress: { (Progress) in
            
        }, success: { (URLSessionDataTask, result) in
            print(result!)
            let dic = result as! Dictionary<NSString, Any>
            let relationVC = RelationViewController(nibName: "RelationViewController", bundle: nil)
            let user = getNewUser()
            user.userId = String(format: "%d", Defaultinfos.getIntValueForKey(key: UserID))
            user.userPh = Defaultinfos.getValueForKey(key: Account) as? String
            user.deviceId = String(format: "%d", dic["DeviceId"] as! Int)
            print("lgepk   \(Defaultinfos.getValueForKey(key: Account))  ***  \(user.userPh)")
            relationVC.user = user
            //记录已选中设备信息
              MBProgressHUD.hide()
            self.view.endEditing(true)
            if dic["State"] as! Int == 0{
                relationVC.isGuardian = true
                self.navigationController?.pushViewController(relationVC, animated: true)
            }
            else if dic["State"] as! Int == 1107{
                relationVC.isGuardian = false
                self.navigationController?.pushViewController(relationVC, animated: true)
            }
            else{
                MBProgressHUD.showError(StrongGoString(object: dic["Message"]))
                self.navigationController?.popViewController(animated: true)
            }
          
        }, failure: { (URLSessionDataTask, Error) in
            MBProgressHUD.hide()
            if (Error as NSError).code == -999{
                return;
            }
            MBProgressHUD.showError(Error.localizedDescription)
        })
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
